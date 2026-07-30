import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

class CategoryDatasource {
  const CategoryDatasource(this._db);
  final AppDatabase _db;

  // Watch all active
  Stream<List<CategoriesTableData>> watchAll() {
    return (_db.select(_db.categoriesTable)
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])
    ).watch();
  }

  // Watch active only
  Stream<List<CategoriesTableData>> watchActive() {
    return (_db.select(_db.categoriesTable)
      ..where((c) => c.isActive.equals(true))
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])
    ).watch();
  }

  // Get all
  Future<List<CategoriesTableData>> getAll() {
    return (_db.select(_db.categoriesTable)
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])
    ).get();
  }

  // Get by id
  Future<CategoriesTableData?> getById(int id) {
    return (_db.select(_db.categoriesTable)
      ..where((c) => c.id.equals(id))
    ).getSingleOrNull();
  }

  // Insert
  Future<int> insert(CategoriesTableCompanion data) {
    return _db.into(_db.categoriesTable).insert(data);
  }

  // Update
  Future<bool> update(CategoriesTableCompanion data) {
    return _db.update(_db.categoriesTable).replace(data);
  }

  // Toggle active
  Future<void> toggleActive(int id, bool isActive) async {
    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.categoriesTable)
      ..where((c) => c.id.equals(id))
    ).write(
      CategoriesTableCompanion(
        isActive: Value(isActive),
        updatedAt: Value(now),
      ),
    );
  }

  // Delete
  Future<int> delete(int id) {
    return (_db.delete(_db.categoriesTable)
      ..where((c) => c.id.equals(id))
    ).go();
  }

  // Check if has products
  Future<bool> hasProducts(int categoryId) async {
    final count = await (_db.select(_db.productsTable)
      ..where((p) => p.categoryId.equals(categoryId))
    ).get();
    return count.isNotEmpty;
  }
}