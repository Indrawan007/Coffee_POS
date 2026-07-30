import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/cart_state_model.dart';
import '../providers/cart_provider.dart';
import '../providers/transaction_provider.dart';
import 'receipt_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() =>
    _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _paymentMethod = 'cash';
  String _paymentLabel  = 'Cash';
  final _amountCtrl = TextEditingController();
  double _amountPaid  = 0;
  double _change      = 0;

  final List<Map<String, String>> _nonCashOptions = [
    {'key': 'QRIS', 'label': 'QRIS'},
    {'key': 'Debit', 'label': 'Kartu Debit'},
    {'key': 'Transfer', 'label': 'Transfer Bank'},
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val, double total) {
    final amount = double.tryParse(
      val.replaceAll('.', ''),
    ) ?? 0;
    setState(() {
      _amountPaid = amount;
      _change     = amount - total;
    });
  }

  void _setQuickAmount(double amount) {
    _amountCtrl.text = amount.toStringAsFixed(0);
    final cart = ref.read(cartNotifierProvider);
    _onAmountChanged(_amountCtrl.text, cart.total);
  }

  bool _canPay(CartStateModel cart) {
    if (_paymentMethod == 'cash') {
      return _amountPaid >= cart.total;
    }
    return true;
  }

  Future<void> _onPay(CartStateModel cart) async {
    final amountPaid = _paymentMethod == 'cash'
      ? _amountPaid
      : cart.total;

    await ref.read(transactionNotifierProvider.notifier)
      .saveTransaction(
        cart: cart,
        paymentMethod: _paymentMethod,
        paymentLabel: _paymentLabel,
        amountPaid: amountPaid,
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartNotifierProvider);

    ref.listen(transactionNotifierProvider, (prev, next) {
      if (next.isSuccess && next.result != null) {
        // Clear cart
        ref.read(cartNotifierProvider.notifier).clearCart();
        ref.read(transactionNotifierProvider.notifier).reset();

        // Navigate ke receipt
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(
              result: next.result!,
            ),
          ),
        );
      }

      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final trxState = ref.watch(transactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          // ── KIRI: Order Summary ──────────────
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Pesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Items
                  ...cart.items.map((item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.displayName),
                    subtitle: item.addonNames.isNotEmpty
                      ? Text(
                          '+ ${item.addonDisplay}',
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                    trailing: Text(
                      '${item.qty}x '
                      '${CurrencyFormatter.format(item.totalPrice)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),

                  const Divider(),

                  // Summary
                  _SummaryRow(
                    'Subtotal',
                    CurrencyFormatter.format(cart.subtotal),
                  ),
                  if (cart.discountAmount > 0)
                    _SummaryRow(
                      'Diskon',
                      '-${CurrencyFormatter.format(cart.discountAmount)}',
                      color: AppColors.success,
                    ),
                  if (cart.taxAmount > 0)
                    _SummaryRow(
                      'Pajak (${cart.taxPercent.toInt()}%)',
                      CurrencyFormatter.format(cart.taxAmount),
                    ),
                  if (cart.serviceAmount > 0)
                    _SummaryRow(
                      'Service (${cart.servicePercent.toInt()}%)',
                      CurrencyFormatter.format(cart.serviceAmount),
                    ),
                  const Divider(),
                  _SummaryRow(
                    'TOTAL',
                    CurrencyFormatter.format(cart.total),
                    isBold: true,
                    fontSize: 18,
                  ),
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 1),

          // ── KANAN: Payment Method ────────────
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Payment method tabs
                  Row(
                    children: [
                      _PayMethodChip(
                        label: '💵 Cash',
                        isSelected: _paymentMethod == 'cash',
                        onTap: () => setState(() {
                          _paymentMethod = 'cash';
                          _paymentLabel  = 'Cash';
                        }),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      ..._nonCashOptions.map((opt) =>
                        Padding(
                          padding: const EdgeInsets.only(
                            right: AppSizes.sm,
                          ),
                          child: _PayMethodChip(
                            label: opt['label']!,
                            isSelected:
                              _paymentLabel == opt['key'],
                            onTap: () => setState(() {
                              _paymentMethod = 'non_cash';
                              _paymentLabel  = opt['key']!;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Cash input
                  if (_paymentMethod == 'cash') ...[
                    const Text(
                      'Jumlah Bayar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onChanged: (v) =>
                        _onAmountChanged(v, cart.total),
                    ),

                    const SizedBox(height: AppSizes.sm),

                    // Quick amount
                    const Text(
                      'Nominal Cepat:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Wrap(
                      spacing: AppSizes.sm,
                      children: _quickAmounts(cart.total)
                        .map((amt) => ActionChip(
                          label: Text(
                            CurrencyFormatter.formatCompact(amt),
                          ),
                          onPressed: () => _setQuickAmount(amt),
                        ))
                        .toList(),
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // Kembalian
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: _change >= 0
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMd,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Kembalian',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _change >= 0
                              ? CurrencyFormatter.format(_change)
                              : 'Kurang ${CurrencyFormatter.format(-_change)}',
                            style: TextStyle(
                              color: _change >= 0
                                ? AppColors.success
                                : AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Non-cash info
                  if (_paymentMethod == 'non_cash') ...[
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMd,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            'Pembayaran via $_paymentLabel\n'
                            'Total: ${CurrencyFormatter.format(cart.total)}',
                            style: const TextStyle(
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSizes.xl),

                  // Pay button
                  ElevatedButton(
                    onPressed: _canPay(cart) && !trxState.isLoading
                      ? () => _onPay(cart)
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(
                        double.infinity, 56,
                      ),
                    ),
                    child: trxState.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          '✅ SELESAIKAN PEMBAYARAN '
                          '${CurrencyFormatter.format(cart.total)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _quickAmounts(double total) {
    final base = [
      10000.0, 20000.0, 50000.0,
      100000.0, 150000.0, 200000.0,
    ];
    return [total, ...base.where((a) => a >= total)]
      .toSet()
      .toList()
      ..sort();
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.color,
    this.fontSize = 14,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold
                ? FontWeight.bold
                : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold
                ? FontWeight.bold
                : FontWeight.normal,
              color: color,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayMethodChip extends StatelessWidget {
  const _PayMethodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
            ? AppColors.primary
            : AppColors.surfaceVar,
          borderRadius: BorderRadius.circular(
            AppSizes.radiusMd,
          ),
          border: Border.all(
            color: isSelected
              ? AppColors.primary
              : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
              ? Colors.white
              : AppColors.textPrimary,
            fontWeight: isSelected
              ? FontWeight.bold
              : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}