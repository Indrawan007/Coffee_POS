// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionDatasourceHash() =>
    r'c086ee2e84bee80620bebac659a7f3d72a61fe4e';

/// See also [transactionDatasource].
@ProviderFor(transactionDatasource)
final transactionDatasourceProvider =
    AutoDisposeProvider<TransactionDatasource>.internal(
  transactionDatasource,
  name: r'transactionDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionDatasourceRef
    = AutoDisposeProviderRef<TransactionDatasource>;
String _$transactionNotifierHash() =>
    r'521d7e60571a5b299e833b6c880fca0c7993e913';

/// See also [TransactionNotifier].
@ProviderFor(TransactionNotifier)
final transactionNotifierProvider =
    AutoDisposeNotifierProvider<TransactionNotifier, TransactionState>.internal(
  TransactionNotifier.new,
  name: r'transactionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionNotifier = AutoDisposeNotifier<TransactionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
