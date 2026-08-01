import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/product_datasource.dart';

part 'product_provider.g.dart';

@riverpod
ProductDatasource productDatasource(Ref ref) {
  return ProductDatasource(AppDatabase.instance);
}

@riverpod
Future<List<ProductWithDetails>> productsWithDetails(
  Ref ref,
) {
  return ref.watch(productDatasourceProvider)
    .getAllWithDetails();
}

final addonsByCategoryProvider =
    FutureProvider.family<List<AddonsTableData>, int>(
  (ref, categoryId) async {
    final ds = ref.watch(productDatasourceProvider);
    return ds.getAddonsByCategory(categoryId);
  },
);

// ─── VARIANT INPUT MODEL ──────────────────────────
class VariantInput {
  VariantInput({
    this.id,
    required this.name,
    required this.priceAdjustment,
  });

  final int? id;
  String name;
  double priceAdjustment;
}

// ─── PRODUCT FORM STATE ───────────────────────────
class ProductFormState {
  const ProductFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  ProductFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError
        ? null
        : errorMessage ?? this.errorMessage,
    );
  }
}

// ─── PRODUCT FORM NOTIFIER ────────────────────────
@riverpod
class ProductFormNotifier extends _$ProductFormNotifier {

  @override
  ProductFormState build() => const ProductFormState();

  Future<void> save({
    int? id,
    required int categoryId,
    required String name,
    String? description,
    required double basePrice,
    String? imagePath,
    required bool isActive,
    required List<VariantInput> variants,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final ds = ref.read(productDatasourceProvider);

      int productId;

      if (id == null) {
        // ── INSERT ────────────────────────────
        final now = DateTime.now().toIso8601String();

        productId = await ds.insert(
          ProductsTableCompanion.insert(
            categoryId: categoryId,
            name: name.trim(),
            description: Value(description),
            basePrice: Value(basePrice),
            imagePath: Value(imagePath),
            isActive: Value(isActive),
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        // ✅ FIX: UPDATE pakai method baru
        productId = id;

        await ds.updateProduct(
          id: id,
          categoryId: categoryId,
          name: name.trim(),
          description: description,
          basePrice: basePrice,
          imagePath: imagePath,
          isActive: isActive,
        );

        // Hapus variants lama
        await ds.deleteVariants(id);
      }

      // ── SAVE VARIANTS ─────────────────────
      final validVariants = variants
        .where((v) => v.name.trim().isNotEmpty)
        .toList();

      if (validVariants.isNotEmpty) {
        await ds.insertVariants(
          validVariants
            .map((v) =>
              ProductVariantsTableCompanion.insert(
                productId: productId,
                name: v.name.trim(),
                priceAdjustment: Value(
                  v.priceAdjustment,
                ),
              ),
            )
            .toList(),
        );
      }

      // ✅ Refresh product list
      ref.invalidate(productsWithDetailsProvider);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan produk: $e',
      );
    }
  }

  Future<void> toggleActive(int id, bool isActive) async {
    await ref
      .read(productDatasourceProvider)
      .toggleActive(id, isActive);
    // ✅ Refresh list
    ref.invalidate(productsWithDetailsProvider);
  }

  Future<void> delete(int id) async {
    await ref.read(productDatasourceProvider).delete(id);
    // ✅ Refresh list
    ref.invalidate(productsWithDetailsProvider);
  }
}