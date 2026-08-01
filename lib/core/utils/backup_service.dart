import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class BackupInfo {
  const BackupInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.createdAt,
  });

  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime createdAt;

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  // ─── BACKUP DATABASE ──────────────────────────
  Future<BackupInfo> createBackup() async {
    try {
      // Source: database file
      final dbFolder =
        await getApplicationDocumentsDirectory();
      final dbFile = File(
        p.join(dbFolder.path, 'coffee_pos.db'),
      );

      if (!await dbFile.exists()) {
        throw Exception('Database tidak ditemukan');
      }

      // Destination: Downloads atau app external
      final backupDir = await _getBackupDirectory();
      await backupDir.create(recursive: true);

      // Filename dengan timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss')
        .format(DateTime.now());
      final fileName = 'coffee_pos_backup_$timestamp.db';
      final backupPath = p.join(backupDir.path, fileName);

      // Copy file
      await dbFile.copy(backupPath);

      final backupFile = File(backupPath);
      final fileSize = await backupFile.length();

      debugPrint('Backup created: $backupPath');
      debugPrint('Backup size: $fileSize bytes');

      return BackupInfo(
        filePath: backupPath,
        fileName: fileName,
        fileSize: fileSize,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Gagal membuat backup: $e');
    }
  }

  // ─── RESTORE DATABASE ─────────────────────────
  Future<void> restoreBackup(String backupFilePath) async {
    try {
      final backupFile = File(backupFilePath);

      if (!await backupFile.exists()) {
        throw Exception('File backup tidak ditemukan');
      }

      // Validasi file
      final fileSize = await backupFile.length();
      if (fileSize < 100) {
        throw Exception(
          'File backup tidak valid (terlalu kecil)',
        );
      }

      // Validasi extension
      if (!backupFilePath.endsWith('.db')) {
        throw Exception(
          'File harus berformat .db',
        );
      }

      // Target: database file
      final dbFolder =
        await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'coffee_pos.db');
      final dbFile = File(dbPath);

      // Backup current database dulu (safety net)
      if (await dbFile.exists()) {
        final safetyPath =
          p.join(dbFolder.path, 'coffee_pos_before_restore.db');
        await dbFile.copy(safetyPath);
        debugPrint('Safety backup: $safetyPath');
      }

      // Replace database
      await backupFile.copy(dbPath);

      debugPrint('Database restored from: $backupFilePath');
    } catch (e) {
      throw Exception('Gagal restore: $e');
    }
  }

  // ─── LIST BACKUPS ─────────────────────────────
  Future<List<BackupInfo>> listBackups() async {
    try {
      final backupDir = await _getBackupDirectory();

      if (!await backupDir.exists()) return [];

      final files = await backupDir
        .list()
        .where((entity) =>
          entity is File &&
          entity.path.endsWith('.db') &&
          p.basename(entity.path)
            .startsWith('coffee_pos_backup'),
        )
        .toList();

      final backups = <BackupInfo>[];

      for (final entity in files) {
        final file = File(entity.path);
        final stat = await file.stat();

        backups.add(BackupInfo(
          filePath: file.path,
          fileName: p.basename(file.path),
          fileSize: stat.size,
          createdAt: stat.modified,
        ));
      }

      // Sort: terbaru di atas
      backups.sort((a, b) =>
        b.createdAt.compareTo(a.createdAt),
      );

      return backups;
    } catch (e) {
      debugPrint('Error listing backups: $e');
      return [];
    }
  }

  // ─── DELETE BACKUP ────────────────────────────
  Future<void> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Gagal menghapus backup: $e');
    }
  }

  // ─── GET BACKUP DIRECTORY ─────────────────────
  Future<Directory> _getBackupDirectory() async {
    // Coba gunakan external storage (Downloads)
    Directory? externalDir;

    try {
      externalDir = await getExternalStorageDirectory();
    } catch (_) {}

    if (externalDir != null) {
      // Simpan di subfolder agar mudah dicari
      return Directory(
        p.join(externalDir.path, 'CoffeePOS_Backup'),
      );
    }

    // Fallback: app documents
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(
      p.join(appDir.path, 'backups'),
    );
  }

  // ─── GET BACKUP PATH ─────────────────────────
  Future<String> getBackupDirectoryPath() async {
    final dir = await _getBackupDirectory();
    return dir.path;
  }

  // ─── GET DB INFO ──────────────────────────────
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final dbFolder =
        await getApplicationDocumentsDirectory();
      final dbFile = File(
        p.join(dbFolder.path, 'coffee_pos.db'),
      );

      if (!await dbFile.exists()) {
        return {'exists': false};
      }

      final stat = await dbFile.stat();

      return {
        'exists': true,
        'path': dbFile.path,
        'size': stat.size,
        'modified': stat.modified,
      };
    } catch (e) {
      return {'exists': false, 'error': e.toString()};
    }
  }
}