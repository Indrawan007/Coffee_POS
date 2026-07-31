import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/product_datasource.dart';

part 'product_provider.g.dart';

// ─── DATASOURCE PROVIDER ──────────────────────────
@Riverpod(keepAlive: true)
ProductDatasource productDatasource(Ref ref) {
  return ProductDatasource(AppDatabase.instance);
}

// ─── PRODUCTS WITH DETAILS ────────────────────────
@riverpod
Future<List<ProductWithDetails>> productsWithDetails(
  Ref ref,
) {
  return ref.watch(productDatasourceProvider)
    .getAllWithDetails();
}

// ─── ACTIVE ADDONS ────────────────────────────────
@riverpod
Future<List<AddonsTableData>> activeAddons(Ref ref) {
  return ref.watch(productDatasourceProvider).getActiveAddons();
}

// ─── VARIANT INPUT MODEL ─────────────────────────
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
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final now = DateTime.now().toIso8601String();
      final ds  = ref.read(productDatasourceProvider);

      int productId;

      if (id == null) {
        // ── INSERT ────────────────────────────────
        productId = await ds.insert(
          ProductsTableCompanion.insert(
            categoryId: categoryId,
            name: name,
            description: Value(description),
            basePrice: Value(basePrice),
            imagePath: Value(imagePath),
            isActive: Value(isActive),
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        // ── UPDATE ────────────────────────────────
        productId = id;
        await ds.update(
          ProductsTableCompanion(
            id: Value(id),
            categoryId: Value(categoryId),
            name: Value(name),
            description: Value(description),
            basePrice: Value(basePrice),
            imagePath: Value(imagePath),
            isActive: Value(isActive),
            updatedAt: Value(now),
          ),
        );
        // Hapus variants lama sebelum insert baru
        await ds.deleteVariants(id);
      }

      // ── SAVE VARIANTS ─────────────────────────
      if (variants.isNotEmpty) {
        await ds.insertVariants(
          variants
            .where((v) => v.name.trim().isNotEmpty)
            .map((v) =>
              ProductVariantsTableCompanion.insert(
                productId: productId,
                name: v.name.trim(),
                priceAdjustment: Value(v.priceAdjustment),
              ),
            )
            .toList(),
        );
      }

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
  }

  Future<void> delete(int id) async {
    await ref.read(productDatasourceProvider).delete(id);
  }
}

// ✅ TAMBAH: Provider addon berdasarkan kategori
final addonsByCategoryProvider =
    FutureProvider.family<List<AddonsTableData>, int>(
  (ref, categoryId) async {
    final ds = ref.watch(productDatasourceProvider);
    final addons = await ds.getAddonsByCategory(categoryId);

    // Jika tidak ada relasi, return kosong
    // (bukan return semua addon)
    return addons;
  },
);