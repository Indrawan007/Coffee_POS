import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/backup_service.dart';

// ─── BACKUP STATE ─────────────────────────────────
class BackupState {
  const BackupState({
    this.isLoading = false,
    this.backups = const [],
    this.lastBackup,
    this.dbInfo,
    this.message,
    this.isError = false,
    this.backupPath,
  });

  final bool isLoading;
  final List<BackupInfo> backups;
  final BackupInfo? lastBackup;
  final Map<String, dynamic>? dbInfo;
  final String? message;
  final bool isError;
  final String? backupPath;

  BackupState copyWith({
    bool? isLoading,
    List<BackupInfo>? backups,
    BackupInfo? lastBackup,
    Map<String, dynamic>? dbInfo,
    String? message,
    bool? isError,
    String? backupPath,
    bool clearMessage = false,
    bool clearLastBackup = false,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      backups: backups ?? this.backups,
      lastBackup: clearLastBackup
        ? null
        : lastBackup ?? this.lastBackup,
      dbInfo: dbInfo ?? this.dbInfo,
      message: clearMessage
        ? null
        : message ?? this.message,
      isError: isError ?? this.isError,
      backupPath: backupPath ?? this.backupPath,
    );
  }
}

// ─── BACKUP NOTIFIER ──────────────────────────────
final backupNotifierProvider =
    StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  return BackupNotifier();
});

class BackupNotifier extends StateNotifier<BackupState> {
  BackupNotifier() : super(const BackupState()) {
    loadData();
  }

  final _service = BackupService.instance;

  // ─── LOAD DATA ──────────────────────────────
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);

    try {
      final backups  = await _service.listBackups();
      final dbInfo   = await _service.getDatabaseInfo();
      final path     = await _service.getBackupDirectoryPath();

      state = state.copyWith(
        isLoading: false,
        backups: backups,
        dbInfo: dbInfo,
        backupPath: path,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Error: $e',
        isError: true,
      );
    }
  }

  // ─── CREATE BACKUP ──────────────────────────
  Future<void> createBackup() async {
    state = state.copyWith(
      isLoading: true,
      clearMessage: true,
    );

    try {
      final backup = await _service.createBackup();

      // Refresh list
      final backups = await _service.listBackups();

      state = state.copyWith(
        isLoading: false,
        lastBackup: backup,
        backups: backups,
        message: 'Backup berhasil dibuat! ✅',
        isError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Gagal backup: $e',
        isError: true,
      );
    }
  }

  // ─── RESTORE BACKUP ────────────────────────
  Future<bool> restoreBackup(String filePath) async {
    state = state.copyWith(
      isLoading: true,
      clearMessage: true,
    );

    try {
      await _service.restoreBackup(filePath);

      state = state.copyWith(
        isLoading: false,
        message:
          'Restore berhasil! ✅\n'
          'Aplikasi perlu di-restart.',
        isError: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Gagal restore: $e',
        isError: true,
      );
      return false;
    }
  }

  // ─── DELETE BACKUP ─────────────────────────
  Future<void> deleteBackup(String filePath) async {
    try {
      await _service.deleteBackup(filePath);
      final backups = await _service.listBackups();

      state = state.copyWith(
        backups: backups,
        message: 'Backup dihapus',
        isError: false,
      );
    } catch (e) {
      state = state.copyWith(
        message: 'Gagal hapus: $e',
        isError: true,
      );
    }
  }

  // ─── CLEAR MESSAGE ─────────────────────────
  void clearMessage() {
    state = state.copyWith(clearMessage: true);
  }
}