import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../pos/presentation/providers/transaction_provider.dart';

part 'report_provider.g.dart';

// ─── SELECTED DATE PROVIDER ───────────────────────
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

// ─── REPORT DATA PROVIDER ─────────────────────────
@riverpod
Future<Map<String, dynamic>> reportSummary(Ref ref) async {
  final date = ref.watch(selectedDateProvider);
  final ds   = ref.watch(transactionDatasourceProvider);
  return ds.getSummary(date);
}

@riverpod
Future<List<TransactionsTableData>> reportTransactions(
  Ref ref,
) async {
  final date = ref.watch(selectedDateProvider);
  final ds   = ref.watch(transactionDatasourceProvider);
  return ds.getByDate(date);
}

@riverpod
Future<List<Map<String, dynamic>>> reportBestSeller(
  Ref ref,
) async {
  final date = ref.watch(selectedDateProvider);
  final ds   = ref.watch(transactionDatasourceProvider);
  return ds.getBestSeller(date);
}