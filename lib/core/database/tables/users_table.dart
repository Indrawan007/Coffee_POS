import 'package:drift/drift.dart';

class UsersTable extends Table {
  @override
  String get tableName => 'users';

  IntColumn get id         => integer().autoIncrement()();
  TextColumn get name      => text().withLength(min: 1, max: 100)();
  TextColumn get username  => text().withLength(min: 3, max: 50).unique()();
  TextColumn get password  => text()();
  TextColumn get role      => text().withDefault(const Constant('cashier'))();
  BoolColumn get isActive  => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}