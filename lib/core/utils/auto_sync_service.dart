import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'google_drive_service.dart';

class AutoSyncService {
  AutoSyncService._();
  static final AutoSyncService instance =
    AutoSyncService._();

  Timer? _syncTimer;
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  final _drive = GoogleDriveService.instance;

  // Callbacks
  void Function(SyncResult)? onSyncComplete;
  void Function(SyncStatus)? onSyncStatusChanged;

  // ─── START AUTO SYNC ──────────────────────────
  void start() {
    debugPrint('AutoSync: Starting...');

    // Periodic sync setiap 5 menit
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _trySync(),
    );

    // Listen connectivity changes
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity()
      .onConnectivityChanged
      .listen((results) {
        final hasInternet = results.any((r) =>
          r != ConnectivityResult.none,
        );
        if (hasInternet) {
          debugPrint('AutoSync: Internet connected');
          _trySync();
        }
      });

    // Initial sync
    Future.delayed(
      const Duration(seconds: 3),
      _trySync,
    );
  }

  // ─── STOP AUTO SYNC ──────────────────────────
  void stop() {
    _syncTimer?.cancel();
    _connectivitySub?.cancel();
    debugPrint('AutoSync: Stopped');
  }

  // ─── TRY SYNC ────────────────────────────────
  Future<void> _trySync() async {
    if (_isSyncing) return;

    // Cek auto sync enabled
    final autoSync = await _drive.isAutoSyncEnabled();
    if (!autoSync) return;

    // Cek signed in
    if (!_drive.isSignedIn) {
      final silentOk = await _drive.silentSignIn();
      if (!silentOk) return;
    }

    // Cek internet
    final connectivity =
      await Connectivity().checkConnectivity();
    final hasInternet = connectivity.any((r) =>
      r != ConnectivityResult.none,
    );
    if (!hasInternet) return;

    // Cek need sync
    final needSync = await _drive.needsSync();
    if (!needSync) {
      // Cek time-based sync (minimal 1 jam sekali)
      final lastSync = await _drive.getLastSyncTime();
      if (lastSync != null) {
        final diff = DateTime.now().difference(lastSync);
        if (diff.inHours < 1) return;
      }
    }

    // Do sync
    _isSyncing = true;
    onSyncStatusChanged?.call(SyncStatus.syncing);

    debugPrint('AutoSync: Uploading...');
    final result = await _drive.uploadBackup();

    _isSyncing = false;
    onSyncComplete?.call(result);
    onSyncStatusChanged?.call(result.status);

    debugPrint('AutoSync: ${result.status} - ${result.message}');
  }

  // ─── FORCE SYNC NOW ──────────────────────────
  Future<SyncResult> syncNow() async {
    if (_isSyncing) {
      return const SyncResult(
        status: SyncStatus.syncing,
        message: 'Sync sedang berjalan',
      );
    }

    if (!_drive.isSignedIn) {
      return const SyncResult(
        status: SyncStatus.notSignedIn,
        message: 'Belum login Google',
      );
    }

    _isSyncing = true;
    onSyncStatusChanged?.call(SyncStatus.syncing);

    final result = await _drive.uploadBackup();

    _isSyncing = false;
    onSyncComplete?.call(result);
    onSyncStatusChanged?.call(result.status);

    return result;
  }

  // ─── MARK DATA CHANGED ───────────────────────
  Future<void> onDataChanged() async {
    await _drive.markNeedSync();
  }
}