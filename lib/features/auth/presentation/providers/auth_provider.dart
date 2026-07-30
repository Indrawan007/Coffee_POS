import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/hash_helper.dart';
import '../../domain/entities/user_entity.dart';
import 'package:drift/drift.dart';

class AuthLocalDatasource {
  const AuthLocalDatasource(this._db);

  final AppDatabase _db;

  static const _keyUserId   = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserRole = 'user_role';

  Future<UserEntity?> login(
    String username,
    String password,
  ) async {
    final hash = HashHelper.hashPassword(password);

    final user = await (_db.select(_db.usersTable)
      ..where((u) =>
        u.username.equals(username) &
        u.password.equals(hash) &
        u.isActive.equals(true),
      )
    ).getSingleOrNull();

    if (user == null) return null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, user.id);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserRole, user.role);

    return UserEntity(
      id: user.id,
      name: user.name,
      username: user.username,
      role: user.role,
      isActive: user.isActive,
    );
  }

  Future<UserEntity?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id    = prefs.getInt(_keyUserId);
    if (id == null) return null;

    final user = await (_db.select(_db.usersTable)
      ..where((u) => u.id.equals(id))
    ).getSingleOrNull();

    if (user == null) return null;

    return UserEntity(
      id: user.id,
      name: user.name,
      username: user.username,
      role: user.role,
      isActive: user.isActive,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserRole);
  }
}