import 'package:drift/drift.dart';

class CategoriesTable extends Table {
  @override
  String get tableName => 'categories';

  IntColumn get id        => integer().autoIncrement()();
  TextColumn get name     => text().withLength(min: 1, max: 100)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt=> text()();
  TextColumn get updatedAt=> text()();
}