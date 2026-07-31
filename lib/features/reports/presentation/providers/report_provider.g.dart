// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportSummaryHash() => r'969e688e07a0e633b213644ca933ef91069a6776';

/// See also [reportSummary].
@ProviderFor(reportSummary)
final reportSummaryProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  reportSummary,
  name: r'reportSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportSummaryRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$reportTransactionsHash() =>
    r'5f58309a96c4f0731ed736b5452badf58cb9505d';

/// See also [reportTransactions].
@ProviderFor(reportTransactions)
final reportTransactionsProvider =
    AutoDisposeFutureProvider<List<TransactionsTableData>>.internal(
  reportTransactions,
  name: r'reportTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportTransactionsRef
    = AutoDisposeFutureProviderRef<List<TransactionsTableData>>;
String _$reportBestSellerHash() => r'aac83029e06b01c62ef7cad425683ee776b699d3';

/// See also [reportBestSeller].
@ProviderFor(reportBestSeller)
final reportBestSellerProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  reportBestSeller,
  name: r'reportBestSellerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportBestSellerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportBestSellerRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$selectedDateHash() => r'3982fe7971ba889f3becfd78002706fd37d2d77c';

/// See also [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
  SelectedDate.new,
  name: r'selectedDateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
