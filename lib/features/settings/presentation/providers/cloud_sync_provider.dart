import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/auto_sync_service.dart';
import '../../../../core/utils/google_drive_service.dart';

class CloudSyncState {
  const CloudSyncState({
    this.isSignedIn = false,
    this.isLoading = false,
    this.isSyncing = false,
    this.autoSyncEnabled = true,
    this.hasInternet = false,
    this.userEmail,
    this.userName,
    this.userPhoto,
    this.lastSyncTime,
    this.cloudBackupInfo,
    this.message,
    this.isError = false,
  });

  final bool isSignedIn;
  final bool isLoading;
  final bool isSyncing;
  final bool autoSyncEnabled;
  final bool hasInternet;
  final String? userEmail;
  final String? userName;
  final String? userPhoto;
  final DateTime? lastSyncTime;
  final Map<String, dynamic>? cloudBackupInfo;
  final String? message;
  final bool isError;

  String get lastSyncFormatted {
    if (lastSyncTime == null) return 'Belum pernah';
    return DateFormat('dd/MM/yyyy HH:mm')
      .format(lastSyncTime!);
  }

  CloudSyncState copyWith({
    bool? isSignedIn,
    bool? isLoading,
    bool? isSyncing,
    bool? autoSyncEnabled,
    bool? hasInternet,
    String? userEmail,
    String? userName,
    String? userPhoto,
    DateTime? lastSyncTime,
    Map<String, dynamic>? cloudBackupInfo,
    String? message,
    bool? isError,
    bool clearMessage = false,
    bool clearUser = false,
  }) {
    return CloudSyncState(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      autoSyncEnabled:
        autoSyncEnabled ?? this.autoSyncEnabled,
      hasInternet: hasInternet ?? this.hasInternet,
      userEmail: clearUser
        ? null
        : userEmail ?? this.userEmail,
      userName: clearUser
        ? null
        : userName ?? this.userName,
      userPhoto: clearUser
        ? null
        : userPhoto ?? this.userPhoto,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      cloudBackupInfo:
        cloudBackupInfo ?? this.cloudBackupInfo,
      message: clearMessage
        ? null
        : message ?? this.message,
      isError: isError ?? this.isError,
    );
  }
}

final cloudSyncProvider = StateNotifierProvider<
    CloudSyncNotifier, CloudSyncState>((ref) {
  return CloudSyncNotifier();
});

class CloudSyncNotifier
    extends StateNotifier<CloudSyncState> {

  CloudSyncNotifier() : super(const CloudSyncState()) {
    _init();
  }

  final _drive    = GoogleDriveService.instance;
  final _autoSync = AutoSyncService.instance;
  StreamSubscription? _connectivitySub;

  Future<void> _init() async {
    // Load settings
    final autoSync = await _drive.isAutoSyncEnabled();
    final lastSync = await _drive.getLastSyncTime();

    // Check connectivity
    final connectivity =
      await Connectivity().checkConnectivity();
    final hasInternet = connectivity.any((r) =>
      r != ConnectivityResult.none,
    );

    state = state.copyWith(
      autoSyncEnabled: autoSync,
      lastSyncTime: lastSync,
      hasInternet: hasInternet,
    );

    // Listen connectivity
    _connectivitySub = Connectivity()
      .onConnectivityChanged
      .listen((results) {
        final internet = results.any((r) =>
          r != ConnectivityResult.none,
        );
        state = state.copyWith(hasInternet: internet);
      });

    // Try silent sign in
    final signedIn = await _drive.silentSignIn();
    if (signedIn) {
      state = state.copyWith(
        isSignedIn: true,
        userEmail: _drive.userEmail,
        userName: _drive.userName,
        userPhoto: _drive.userPhoto,
      );

      // Load cloud info
      _loadCloudInfo();

      // Start auto sync
      if (autoSync) {
        _autoSync.onSyncComplete = (result) {
          state = state.copyWith(
            isSyncing: false,
            lastSyncTime: result.lastSyncTime,
            message: result.message,
            isError:
              result.status == SyncStatus.error,
          );
        };
        _autoSync.start();
      }
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _autoSync.stop();
    super.dispose();
  }

  // ─── SIGN IN ──────────────────────────────────
  Future<void> signIn() async {
    state = state.copyWith(
      isLoading: true,
      clearMessage: true,
    );

    final success = await _drive.signIn();

    if (success) {
      state = state.copyWith(
        isLoading: false,
        isSignedIn: true,
        userEmail: _drive.userEmail,
        userName: _drive.userName,
        userPhoto: _drive.userPhoto,
        message: 'Berhasil login Google',
        isError: false,
      );

      _loadCloudInfo();

      if (state.autoSyncEnabled) {
        _autoSync.start();
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        message: 'Login Google dibatalkan',
        isError: true,
      );
    }
  }

  // ─── SIGN OUT ─────────────────────────────────
  Future<void> signOut() async {
    await _drive.signOut();
    _autoSync.stop();

    state = state.copyWith(
      isSignedIn: false,
      clearUser: true,
      message: 'Google account disconnected',
      isError: false,
    );
  }

  // ─── SYNC NOW ─────────────────────────────────
  Future<void> syncNow() async {
    state = state.copyWith(
      isSyncing: true,
      clearMessage: true,
    );

    final result = await _autoSync.syncNow();

    state = state.copyWith(
      isSyncing: false,
      lastSyncTime: result.lastSyncTime,
      message: result.message,
      isError: result.status == SyncStatus.error,
    );
  }

  // ─── RESTORE FROM CLOUD ───────────────────────
  Future<bool> restoreFromCloud() async {
    state = state.copyWith(
      isLoading: true,
      clearMessage: true,
    );

    final result = await _drive.downloadBackup();

    state = state.copyWith(
      isLoading: false,
      message: result.message,
      isError: result.status == SyncStatus.error,
    );

    return result.status == SyncStatus.success;
  }

  // ─── TOGGLE AUTO SYNC ─────────────────────────
  Future<void> toggleAutoSync(bool enabled) async {
    await _drive.setAutoSync(enabled);

    if (enabled && state.isSignedIn) {
      _autoSync.start();
    } else {
      _autoSync.stop();
    }

    state = state.copyWith(autoSyncEnabled: enabled);
  }

  // ─── LOAD CLOUD INFO ─────────────────────────
  Future<void> _loadCloudInfo() async {
    final info = await _drive.getCloudBackupInfo();
    state = state.copyWith(cloudBackupInfo: info);
  }

  void clearMessage() {
    state = state.copyWith(clearMessage: true);
  }
}
