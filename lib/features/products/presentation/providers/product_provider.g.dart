// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productDatasourceHash() => r'5ade77c9803a0e45469fa216019b38d40d78f19a';

/// See also [productDatasource].
@ProviderFor(productDatasource)
final productDatasourceProvider =
    AutoDisposeProvider<ProductDatasource>.internal(
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
typedef ProductDatasourceRef = AutoDisposeProviderRef<ProductDatasource>;
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
String _$productFormNotifierHash() =>
    r'3f5e399a798e6ccc01f1c498afdcbc0a8558712d';

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
