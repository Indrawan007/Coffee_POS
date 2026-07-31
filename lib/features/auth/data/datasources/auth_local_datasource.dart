import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/hash_helper.dart';
import '../../domain/entities/user_entity.dart';

class AuthLocalDatasource {
  const AuthLocalDatasource(this._db);
  final AppDatabase _db;

  static const _keyUserId   = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserRole = 'user_role';

  // ─── LOGIN ──────────────────────────────────
  Future<UserEntity?> login(
    String username,
    String password,
  ) async {
    final hash = HashHelper.hashPassword(password);

    debugPrint('Login attempt: $username');
    debugPrint('Hash: $hash');

    final user = await (
      _db.select(_db.usersTable)
        ..where((u) =>
          u.username.equals(username) &
          u.password.equals(hash) &
          u.isActive.equals(true),
        )
    ).getSingleOrNull();

    debugPrint('User found: ${user?.name}');

    if (user == null) return null;

    await _saveSession(user.id, user.name, user.role);

    return UserEntity(
      id: user.id,
      name: user.name,
      username: user.username,
      role: user.role,
      isActive: user.isActive,
    );
  }

  // ─── REGISTER ───────────────────────────────
  Future<UserEntity> register({
    required String storeName,
    required String name,
    required String username,
    required String password,
  }) async {
    final now  = DateTime.now().toIso8601String();
    final hash = HashHelper.hashPassword(password);

    // Cek username sudah ada
    final existing = await (
      _db.select(_db.usersTable)
        ..where((u) => u.username.equals(username))
    ).getSingleOrNull();

    if (existing != null) {
      throw Exception(
        'Username "$username" sudah digunakan. '
        'Pilih username lain.',
      );
    }

    // Update nama toko di settings
    await (_db.update(_db.settingsTable)).write(
      SettingsTableCompanion(
        storeName: Value(storeName.trim()),
        updatedAt: Value(now),
      ),
    );

    // Insert admin user
    final userId = await _db.into(_db.usersTable).insert(
      UsersTableCompanion.insert(
        name: name.trim(),
        username: username.trim(),
        password: hash,
        role: const Value('admin'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _saveSession(userId, name.trim(), 'admin');

    return UserEntity(
      id: userId,
      name: name.trim(),
      username: username.trim(),
      role: 'admin',
      isActive: true,
    );
  }

  // ─── GET SESSION ────────────────────────────
  Future<UserEntity?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id    = prefs.getInt(_keyUserId);
    if (id == null) return null;

    final user = await (
      _db.select(_db.usersTable)
        ..where((u) =>
          u.id.equals(id) &
          u.isActive.equals(true),
        )
    ).getSingleOrNull();

    if (user == null) {
      await logout();
      return null;
    }

    return UserEntity(
      id: user.id,
      name: user.name,
      username: user.username,
      role: user.role,
      isActive: user.isActive,
    );
  }

  // ─── LOGOUT ─────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserRole);
  }

  // ─── SAVE SESSION ────────────────────────────
  Future<void> _saveSession(
    int id,
    String name,
    String role,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, id);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserRole, role);
  }
}