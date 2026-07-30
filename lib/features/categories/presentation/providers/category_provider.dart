import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/category_datasource.dart';

part 'category_provider.g.dart';

// ─── DATASOURCE PROVIDER ──────────────────────────
@riverpod
CategoryDatasource categoryDatasource(Ref ref) {
  return CategoryDatasource(ref.watch(appDatabaseProvider));
}

// ─── STREAMS ──────────────────────────────────────
@riverpod
Stream<List<CategoriesTableData>> categoriesStream(Ref ref) {
  return ref.watch(categoryDatasourceProvider).watchAll();
}

@riverpod
Stream<List<CategoriesTableData>> activeCategoriesStream(Ref ref) {
  return ref.watch(categoryDatasourceProvider).watchActive();
}

// ─── CATEGORY FORM STATE ──────────────────────────
class CategoryFormState {
  const CategoryFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  CategoryFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return CategoryFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
        ? null
        : errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ─── CATEGORY FORM NOTIFIER ───────────────────────
@riverpod
class CategoryFormNotifier extends _$CategoryFormNotifier {

  @override
  CategoryFormState build() => const CategoryFormState();

  Future<void> save({
    int? id,
    required String name,
    required int sortOrder,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final now = DateTime.now().toIso8601String();
      final ds  = ref.read(categoryDatasourceProvider);

      if (id == null) {
        await ds.insert(
          CategoriesTableCompanion.insert(
            name: name,
            sortOrder: Value(sortOrder),
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        await ds.update(
          CategoriesTableCompanion(
            id: Value(id),
            name: Value(name),
            sortOrder: Value(sortOrder),
            updatedAt: Value(now),
          ),
        );
      }

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan kategori: $e',
      );
    }
  }

  Future<void> toggleActive(int id, bool isActive) async {
    await ref
      .read(categoryDatasourceProvider)
      .toggleActive(id, isActive);
  }

  Future<bool> delete(int id) async {
    final ds       = ref.read(categoryDatasourceProvider);
    final hasProds = await ds.hasProducts(id);

    if (hasProds) return false;

    await ds.delete(id);
    return true;
  }
}