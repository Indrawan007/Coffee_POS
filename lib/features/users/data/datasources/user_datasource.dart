import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/hash_helper.dart';

class UserDatasource {
  const UserDatasource(this._db);
  final AppDatabase _db;

  // Watch all users
  Stream<List<UsersTableData>> watchAll() {
    return (_db.select(_db.usersTable)
      ..orderBy([(u) => OrderingTerm.asc(u.name)])
    ).watch();
  }

  // Get by id
  Future<UsersTableData?> getById(int id) {
    return (_db.select(_db.usersTable)
      ..where((u) => u.id.equals(id))
    ).getSingleOrNull();
  }

  // Insert
  Future<int> insert({
    required String name,
    required String username,
    required String password,
    required String role,
  }) async {
    // Cek username unik
    final existing = await (_db.select(_db.usersTable)
      ..where((u) => u.username.equals(username))
    ).getSingleOrNull();

    if (existing != null) {
      throw Exception(
        'Username "$username" sudah digunakan.',
      );
    }

    final now  = DateTime.now().toIso8601String();
    final hash = HashHelper.hashPassword(password);

    return _db.into(_db.usersTable).insert(
      UsersTableCompanion.insert(
        name: name.trim(),
        username: username.trim(),
        password: hash,
        role: Value(role),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  // Update
  Future<void> update({
    required int id,
    required String name,
    required String username,
    required String role,
  }) async {
    // Cek username unik (kecuali milik sendiri)
    final existing = await (_db.select(_db.usersTable)
      ..where((u) =>
        u.username.equals(username) &
        u.id.isNotIn([id]),
      )
    ).getSingleOrNull();

    if (existing != null) {
      throw Exception(
        'Username "$username" sudah digunakan.',
      );
    }

    final now = DateTime.now().toIso8601String();

    await (_db.update(_db.usersTable)
      ..where((u) => u.id.equals(id))
    ).write(
      UsersTableCompanion(
        name: Value(name.trim()),
        username: Value(username.trim()),
        role: Value(role),
        updatedAt: Value(now),
      ),
    );
  }

  // Reset password
  Future<void> resetPassword({
    required int id,
    required String newPassword,
  }) async {
    final now  = DateTime.now().toIso8601String();
    final hash = HashHelper.hashPassword(newPassword);

    await (_db.update(_db.usersTable)
      ..where((u) => u.id.equals(id))
    ).write(
      UsersTableCompanion(
        password: Value(hash),
        updatedAt: Value(now),
      ),
    );
  }

  // Toggle active
  Future<void> toggleActive(int id, bool isActive) async {
    final now = DateTime.now().toIso8601String();

    await (_db.update(_db.usersTable)
      ..where((u) => u.id.equals(id))
    ).write(
      UsersTableCompanion(
        isActive: Value(isActive),
        updatedAt: Value(now),
      ),
    );
  }

  // Delete
  Future<void> delete(int id) async {
    await (_db.delete(_db.usersTable)
      ..where((u) => u.id.equals(id))
    ).go();
  }
}