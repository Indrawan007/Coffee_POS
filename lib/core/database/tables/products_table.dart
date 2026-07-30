import 'package:drift/drift.dart';
import 'categories_table.dart';

class ProductsTable extends Table {
  @override
  String get tableName => 'products';

  IntColumn get id          => integer().autoIncrement()();
  IntColumn get categoryId  => integer().references(
    CategoriesTable, #id,
  )();
  TextColumn get name       => text().withLength(min: 1, max: 100)();
  TextColumn get description=> text().nullable()();
  RealColumn get basePrice  => real().withDefault(const Constant(0))();
  TextColumn get imagePath  => text().nullable()();
  BoolColumn get isActive   => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt  => text()();
  TextColumn get updatedAt  => text()();
}