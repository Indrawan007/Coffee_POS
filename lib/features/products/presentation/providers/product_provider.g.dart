// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productDatasourceHash() => r'fa51252d162239fa3ce55689d482abd145e36800';

/// See also [productDatasource].
@ProviderFor(productDatasource)
final productDatasourceProvider = Provider<ProductDatasource>.internal(
  productDatasource,
  name: r'productDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductDatasourceRef = ProviderRef<ProductDatasource>;
String _$productsWithDetailsHash() =>
    r'd6b56ff6a05d00f97128f5718e5f7bad82494f81';

/// See also [productsWithDetails].
@ProviderFor(productsWithDetails)
final productsWithDetailsProvider =
    AutoDisposeFutureProvider<List<ProductWithDetails>>.internal(
  productsWithDetails,
  name: r'productsWithDetailsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productsWithDetailsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductsWithDetailsRef
    = AutoDisposeFutureProviderRef<List<ProductWithDetails>>;
String _$activeAddonsHash() => r'e98bd38e523a23eaad51b265da411c833c073a72';

/// See also [activeAddons].
@ProviderFor(activeAddons)
final activeAddonsProvider =
    AutoDisposeFutureProvider<List<AddonsTableData>>.internal(
  activeAddons,
  name: r'activeAddonsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeAddonsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveAddonsRef = AutoDisposeFutureProviderRef<List<AddonsTableData>>;
String _$productFormNotifierHash() =>
    r'12ffc3d24eeebab4bc01c6e83a41b24ad4eed686';

/// See also [ProductFormNotifier].
@ProviderFor(ProductFormNotifier)
final productFormNotifierProvider =
    AutoDisposeNotifierProvider<ProductFormNotifier, ProductFormState>.internal(
  ProductFormNotifier.new,
  name: r'productFormNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productFormNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductFormNotifier = AutoDisposeNotifier<ProductFormState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
