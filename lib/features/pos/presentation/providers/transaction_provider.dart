import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/transaction_datasource.dart';
import '../../domain/models/cart_state_model.dart';

part 'transaction_provider.g.dart';

@riverpod
TransactionDatasource transactionDatasource(Ref ref) {
  return TransactionDatasource(ref.watch(appDatabaseProvider));
}

// ─── TRANSACTION STATE ────────────────────────────
class TransactionState {
  const TransactionState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  final bool isLoading;
  final TransactionResult? result;
  final String? errorMessage;

  bool get isSuccess => result != null;

  TransactionState copyWith({
    bool? isLoading,
    TransactionResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError
        ? null
        : errorMessage ?? this.errorMessage,
    );
  }
}

// ─── TRANSACTION NOTIFIER ─────────────────────────
@riverpod
class TransactionNotifier extends _$TransactionNotifier {

  @override
  TransactionState build() => const TransactionState();

  Future<void> saveTransaction({
    required CartStateModel cart,
    required String paymentMethod,
    String? paymentLabel,
    required double amountPaid,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearResult: true,
    );

    try {
      final authState = ref.read(authNotifierProvider);
      final user      = authState.user;

      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Session expired. Silakan login ulang.',
        );
        return;
      }

      final result = await ref
        .read(transactionDatasourceProvider)
        .saveTransaction(
          cart: cart,
          cashierId: user.id,
          cashierName: user.name,
          paymentMethod: paymentMethod,
          paymentLabel: paymentLabel,
          amountPaid: amountPaid,
        );

      state = state.copyWith(
        isLoading: false,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan transaksi: $e',
      );
    }
  }

  void reset() {
    state = const TransactionState();
  }
}