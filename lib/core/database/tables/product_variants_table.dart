import 'package:drift/drift.dart';
import 'products_table.dart';

class ProductVariantsTable extends Table {
  @override
  String get tableName => 'product_variants';

  IntColumn get id              => integer().autoIncrement()();
  IntColumn get productId       => integer().references(
    ProductsTable, #id,
  )();
  TextColumn get name           => text()();
  RealColumn get priceAdjustment=> real().withDefault(const Constant(0))();
  BoolColumn get isActive       => boolean().withDefault(const Constant(true))();
}