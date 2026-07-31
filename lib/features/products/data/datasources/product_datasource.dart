import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

class ProductWithDetails {
  const ProductWithDetails({
    required this.product,
    required this.variants,
    required this.category,
  });
  final ProductsTableData product;
  final List<ProductVariantsTableData> variants;
  final CategoriesTableData category;
}

class ProductDatasource {
  const ProductDatasource(this._db);
  final AppDatabase _db;

  // Watch all products
  Stream<List<ProductsTableData>> watchAll() {
    return (_db.select(_db.productsTable)
      ..orderBy([(p) => OrderingTerm.asc(p.name)])
    ).watch();
  }

  // Get all with details
  Future<List<ProductWithDetails>> getAllWithDetails() async {
    final products = await (_db.select(_db.productsTable)
      ..orderBy([(p) => OrderingTerm.asc(p.name)])
    ).get();

    final result = <ProductWithDetails>[];

    for (final product in products) {
      final variants = await (_db.select(_db.productVariantsTable)
        ..where((v) => v.productId.equals(product.id))
        ..where((v) => v.isActive.equals(true))
      ).get();

      final category = await (_db.select(_db.categoriesTable)
        ..where((c) => c.id.equals(product.categoryId))
      ).getSingle();

      result.add(ProductWithDetails(
        product: product,
        variants: variants,
        category: category,
      ));
    }

    return result;
  }

  // Get by id with details
  Future<ProductWithDetails?> getByIdWithDetails(int id) async {
    final product = await (_db.select(_db.productsTable)
      ..where((p) => p.id.equals(id))
    ).getSingleOrNull();

    if (product == null) return null;

    final variants = await (_db.select(_db.productVariantsTable)
      ..where((v) => v.productId.equals(id))
    ).get();

    final category = await (_db.select(_db.categoriesTable)
      ..where((c) => c.id.equals(product.categoryId))
    ).getSingle();

    return ProductWithDetails(
      product: product,
      variants: variants,
      category: category,
    );
  }

  // ✅ TAMBAH: Get addons berdasarkan categoryId produk
  Future<List<AddonsTableData>> getAddonsByCategory(
    int categoryId,
  ) async {
    return _db.getAddonsByCategory(categoryId);
  }

  // ✅ TAMBAH: Get semua addons (untuk fallback)
  Future<List<AddonsTableData>> getActiveAddons() {
    return (_db.select(_db.addonsTable)
      ..where((a) => a.isActive.equals(true))
    ).get();
  }

  Stream<List<ProductsTableData>> watchByCategory(
    int categoryId,
  ) {
    return (_db.select(_db.productsTable)
      ..where((p) =>
        p.categoryId.equals(categoryId) &
        p.isActive.equals(true),
      )
      ..orderBy([(p) => OrderingTerm.asc(p.name)])
    ).watch();
  }

  Future<int> insert(ProductsTableCompanion data) {
    return _db.into(_db.productsTable).insert(data);
  }

  Future<bool> update(ProductsTableCompanion data) {
    return _db.update(_db.productsTable).replace(data);
  }

  Future<void> deleteVariants(int productId) {
    return (_db.delete(_db.productVariantsTable)
      ..where((v) => v.productId.equals(productId))
    ).go();
  }

  Future<void> insertVariants(
    List<ProductVariantsTableCompanion> variants,
  ) async {
    await _db.batch((b) {
      b.insertAll(_db.productVariantsTable, variants);
    });
  }

  Future<void> toggleActive(int id, bool isActive) async {
    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.productsTable)
      ..where((p) => p.id.equals(id))
    ).write(
      ProductsTableCompanion(
        isActive: Value(isActive),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> delete(int id) async {
    await deleteVariants(id);
    await (_db.delete(_db.productsTable)
      ..where((p) => p.id.equals(id))
    ).go();
  }

  Future<List<ProductVariantsTableData>> getVariants(
    int productId,
  ) {
    return (_db.select(_db.productVariantsTable)
      ..where((v) => v.productId.equals(productId))
      ..where((v) => v.isActive.equals(true))
    ).get();
  }
}