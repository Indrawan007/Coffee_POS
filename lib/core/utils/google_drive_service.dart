import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

// ─── AUTH HTTP CLIENT ─────────────────────────────
class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  @override
  Future<http.StreamedResponse> send(
    http.BaseRequest request,
  ) {
    return _client.send(request..headers.addAll(_headers));
  }
}

// ─── SYNC STATUS ──────────────────────────────────
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  noInternet,
  notSignedIn,
}

class SyncResult {
  const SyncResult({
    required this.status,
    this.message,
    this.lastSyncTime,
  });

  final SyncStatus status;
  final String? message;
  final DateTime? lastSyncTime;
}

// ─── GOOGLE DRIVE SERVICE ─────────────────────────
class GoogleDriveService {
  GoogleDriveService._();
  static final GoogleDriveService instance =
    GoogleDriveService._();

  static const _folderName = 'CoffeePOS_Backup';
  static const _fileName   = 'coffee_pos_backup.db';
  static const _prefKeyLastSync = 'last_google_sync';
  static const _prefKeyAutoSync = 'auto_sync_enabled';
  static const _prefKeyNeedSync = 'need_sync';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
      drive.DriveApi.driveAppdataScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  // ─── GETTERS ──────────────────────────────────
  bool get isSignedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;
  String? get userPhoto => _currentUser?.photoUrl;

  // ─── SIGN IN ──────────────────────────────────
  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();

      if (_currentUser == null) return false;

      await _initDriveApi();

      debugPrint(
        'Google Sign In: ${_currentUser!.email}',
      );

      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  // ─── SILENT SIGN IN ───────────────────────────
  Future<bool> silentSignIn() async {
    try {
      _currentUser =
        await _googleSignIn.signInSilently();

      if (_currentUser == null) return false;

      await _initDriveApi();
      return true;
    } catch (e) {
      debugPrint('Silent sign in error: $e');
      return false;
    }
  }

  // ─── SIGN OUT ─────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  // ─── INIT DRIVE API ───────────────────────────
  Future<void> _initDriveApi() async {
    if (_currentUser == null) return;

    final authHeaders =
      await _currentUser!.authHeaders;
    final client = _GoogleAuthClient(authHeaders);
    _driveApi = drive.DriveApi(client);
  }

  // ─── UPLOAD BACKUP ────────────────────────────
  Future<SyncResult> uploadBackup() async {
    try {
      if (_driveApi == null) {
        return const SyncResult(
          status: SyncStatus.notSignedIn,
          message: 'Belum login Google',
        );
      }

      // Get database file
      final dbFolder =
        await getApplicationDocumentsDirectory();
      final dbFile = File(
        p.join(dbFolder.path, 'coffee_pos.db'),
      );

      if (!await dbFile.exists()) {
        return const SyncResult(
          status: SyncStatus.error,
          message: 'Database tidak ditemukan',
        );
      }

      // Find or create folder
      final folderId = await _getOrCreateFolder();

      // Check existing file
      final existingFileId =
        await _findBackupFile(folderId);

      // Upload media
      final media = drive.Media(
        dbFile.openRead(),
        await dbFile.length(),
      );

      if (existingFileId != null) {
        // ✅ FIX: Update TANPA parents
        final updateFile = drive.File()
          ..name = _fileName
          ..mimeType = 'application/octet-stream'
          ..description =
            'Coffee POS Backup - '
            '${DateTime.now().toIso8601String()}';

        // ✅ Jangan set parents saat update
        await _driveApi!.files.update(
          updateFile,
          existingFileId,
          uploadMedia: media,
        );
        debugPrint('Backup updated on Drive');
      } else {
        // ✅ Create baru DENGAN parents
        final createFile = drive.File()
          ..name = _fileName
          ..parents = [folderId]
          ..mimeType = 'application/octet-stream'
          ..description =
            'Coffee POS Backup - '
            '${DateTime.now().toIso8601String()}';

        await _driveApi!.files.create(
          createFile,
          uploadMedia: media,
        );
        debugPrint('Backup created on Drive');
      }

      // Save last sync time
      final now = DateTime.now();
      await _saveLastSyncTime(now);
      await _clearNeedSync();

      return SyncResult(
        status: SyncStatus.success,
        message: 'Backup berhasil di-sync ✅',
        lastSyncTime: now,
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      return SyncResult(
        status: SyncStatus.error,
        message: 'Gagal upload: $e',
      );
    }
  }
  // ─── DOWNLOAD BACKUP ─────────────────────────
  Future<SyncResult> downloadBackup() async {
    try {
      if (_driveApi == null) {
        return const SyncResult(
          status: SyncStatus.notSignedIn,
          message: 'Belum login Google',
        );
      }

      final folderId = await _getOrCreateFolder();
      final fileId   = await _findBackupFile(folderId);

      if (fileId == null) {
        return const SyncResult(
          status: SyncStatus.error,
          message: 'Tidak ada backup di Google Drive',
        );
      }

      // Download file
      final response = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // Save to local
      final dbFolder =
        await getApplicationDocumentsDirectory();

      // Safety backup current db
      final currentDb = File(
        p.join(dbFolder.path, 'coffee_pos.db'),
      );
      if (await currentDb.exists()) {
        await currentDb.copy(
          p.join(
            dbFolder.path,
            'coffee_pos_before_cloud_restore.db',
          ),
        );
      }

      // Write downloaded file
      final dbPath =
        p.join(dbFolder.path, 'coffee_pos.db');
      final file = File(dbPath);
      final sink = file.openWrite();

      await response.stream.pipe(sink);
      await sink.close();

      final now = DateTime.now();
      await _saveLastSyncTime(now);

      debugPrint('Backup downloaded from Drive');

      return SyncResult(
        status: SyncStatus.success,
        message: 'Data berhasil di-restore dari cloud',
        lastSyncTime: now,
      );
    } catch (e) {
      debugPrint('Download error: $e');
      return SyncResult(
        status: SyncStatus.error,
        message: 'Gagal download: $e',
      );
    }
  }

  // ─── CHECK CLOUD BACKUP EXISTS ────────────────
  Future<bool> hasCloudBackup() async {
    try {
      if (_driveApi == null) return false;

      final folderId = await _getOrCreateFolder();
      final fileId   = await _findBackupFile(folderId);

      return fileId != null;
    } catch (e) {
      return false;
    }
  }

  // ─── GET CLOUD BACKUP INFO ────────────────────
  Future<Map<String, dynamic>?> getCloudBackupInfo() async {
    try {
      if (_driveApi == null) return null;

      final folderId = await _getOrCreateFolder();
      final fileId   = await _findBackupFile(folderId);

      if (fileId == null) return null;

      final file = await _driveApi!.files.get(
        fileId,
        $fields: 'id,name,size,modifiedTime,description',
      ) as drive.File;

      return {
        'name': file.name,
        'size': int.tryParse(file.size ?? '0') ?? 0,
        'modified': file.modifiedTime,
        'description': file.description,
      };
    } catch (e) {
      return null;
    }
  }

  // ─── FOLDER HELPERS ───────────────────────────
  Future<String> _getOrCreateFolder() async {
    // Search folder
    const query =
      "name='$_folderName' and "
      "mimeType='application/vnd.google-apps.folder' and "
      "trashed=false";

    final result = await _driveApi!.files.list(
      q: query,
      spaces: 'drive',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    // Create folder
    final folder = drive.File()
      ..name = _folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final created = await _driveApi!.files.create(folder);

    debugPrint('Created Drive folder: ${created.id}');

    return created.id!;
  }

  Future<String?> _findBackupFile(String folderId) async {
    final query =
      "name='$_fileName' and "
      "'$folderId' in parents and "
      "trashed=false";

    final result = await _driveApi!.files.list(
      q: query,
      spaces: 'drive',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    return null;
  }

  // ─── PREFS HELPERS ────────────────────────────
  Future<void> _saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKeyLastSync,
      time.toIso8601String(),
    );
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str   = prefs.getString(_prefKeyLastSync);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  Future<void> setAutoSync(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyAutoSync, enabled);
  }

  Future<bool> isAutoSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyAutoSync) ?? true;
  }

  Future<void> markNeedSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyNeedSync, true);
  }

  Future<bool> needsSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyNeedSync) ?? false;
  }

  Future<void> _clearNeedSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyNeedSync, false);
  }
}
