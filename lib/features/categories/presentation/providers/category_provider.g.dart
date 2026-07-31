// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryDatasourceHash() =>
    r'50d9272cbf7db44a6d97acb7a6f7a6c29a8d04f9';

/// See also [categoryDatasource].
@ProviderFor(categoryDatasource)
final categoryDatasourceProvider =
    AutoDisposeProvider<CategoryDatasource>.internal(
  categoryDatasource,
  name: r'categoryDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryDatasourceRef = AutoDisposeProviderRef<CategoryDatasource>;
String _$categoriesStreamHash() => r'6058d826626473c06e1f921df77dbb7446028fca';

/// See also [categoriesStream].
@ProviderFor(categoriesStream)
final categoriesStreamProvider =
    AutoDisposeStreamProvider<List<CategoriesTableData>>.internal(
  categoriesStream,
  name: r'categoriesStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoriesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesStreamRef
    = AutoDisposeStreamProviderRef<List<CategoriesTableData>>;
String _$activeCategoriesStreamHash() =>
    r'01fd7a7700067e6603d07520662cb5dfd494015d';

/// See also [activeCategoriesStream].
@ProviderFor(activeCategoriesStream)
final activeCategoriesStreamProvider =
    AutoDisposeStreamProvider<List<CategoriesTableData>>.internal(
  activeCategoriesStream,
  name: r'activeCategoriesStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeCategoriesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveCategoriesStreamRef
    = AutoDisposeStreamProviderRef<List<CategoriesTableData>>;
String _$categoryFormNotifierHash() =>
    r'aeb3ec5e7440c1971a71c9cfd3d7d362c27e94a2';

/// See also [CategoryFormNotifier].
@ProviderFor(CategoryFormNotifier)
final categoryFormNotifierProvider = AutoDisposeNotifierProvider<
    CategoryFormNotifier, CategoryFormState>.internal(
  CategoryFormNotifier.new,
  name: r'categoryFormNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryFormNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoryFormNotifier = AutoDisposeNotifier<CategoryFormState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
