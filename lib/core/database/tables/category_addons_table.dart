import 'package:drift/drift.dart';
import 'categories_table.dart';
import 'addons_table.dart';

class CategoryAddonsTable extends Table {
  @override
  String get tableName => 'category_addons';

  IntColumn get id         => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(
    CategoriesTable, #id,
  )();
  IntColumn get addonId    => integer().references(
    AddonsTable, #id,
  )();
}