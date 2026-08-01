import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/cart_item_model.dart';
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

class _PaymentScreenState
    extends ConsumerState<PaymentScreen> {

  String _paymentMethod = 'cash';
  String _paymentLabel  = 'Cash';
  final _amountCtrl     = TextEditingController();
  double _amountPaid    = 0;
  bool _summaryExpanded = true;

  final List<Map<String, String>> _nonCashOptions = [
    {'key': 'QRIS', 'label': 'QRIS'},
    {'key': 'Debit', 'label': 'Debit'},
    {'key': 'Transfer', 'label': 'Transfer'},
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
    setState(() => _amountPaid = amount);
  }

  void _setQuickAmount(double amount) {
    _amountCtrl.text = amount.toStringAsFixed(0);
    final cart = ref.read(cartNotifierProvider);
    _onAmountChanged(_amountCtrl.text, cart.total);
  }

  bool _canPay(CartStateModel cart) {
    if (cart.isEmpty) return false;
    if (_paymentMethod == 'cash') {
      return _amountPaid >= cart.total;
    }
    return true;
  }

  double _getChange(double total) {
    if (_paymentMethod != 'cash') return 0;
    return _amountPaid - total;
  }

  Future<void> _onPay(CartStateModel cart) async {
    final amountPaid = _paymentMethod == 'cash'
      ? _amountPaid
      : cart.total;

    await ref
      .read(transactionNotifierProvider.notifier)
      .saveTransaction(
        cart: cart,
        paymentMethod: _paymentMethod,
        paymentLabel: _paymentLabel,
        amountPaid: amountPaid,
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart     = ref.watch(cartNotifierProvider);
    final trxState = ref.watch(transactionNotifierProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide      = screenWidth >= 800;

    // Listen transaction result
    ref.listen(transactionNotifierProvider, (prev, next) {
      if (next.isSuccess && next.result != null) {
        // Clear cart
        ref.read(cartNotifierProvider.notifier).clearCart();

        // ✅ Reset transaction state
        final savedResult = next.result!;
        ref.read(transactionNotifierProvider.notifier).reset();

        // ✅ Navigate ke receipt - pushReplacement
        // agar tidak bisa back ke payment
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(
              result: savedResult,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isWide
        ? _WidePaymentLayout(
            cart: cart,
            trxState: trxState,
            paymentMethod: _paymentMethod,
            paymentLabel: _paymentLabel,
            amountCtrl: _amountCtrl,
            amountPaid: _amountPaid,
            change: _getChange(cart.total),
            canPay: _canPay(cart),
            nonCashOptions: _nonCashOptions,
            onMethodChanged: (method, label) =>
              setState(() {
                _paymentMethod = method;
                _paymentLabel  = label;
              }),
            onAmountChanged: (val) =>
              _onAmountChanged(val, cart.total),
            onQuickAmount: _setQuickAmount,
            onPay: () => _onPay(cart),
            quickAmounts: _quickAmounts(cart.total),
          )
        : _CompactPaymentLayout(
            cart: cart,
            trxState: trxState,
            paymentMethod: _paymentMethod,
            paymentLabel: _paymentLabel,
            amountCtrl: _amountCtrl,
            amountPaid: _amountPaid,
            change: _getChange(cart.total),
            canPay: _canPay(cart),
            nonCashOptions: _nonCashOptions,
            summaryExpanded: _summaryExpanded,
            onToggleSummary: () => setState(
              () => _summaryExpanded = !_summaryExpanded,
            ),
            onMethodChanged: (method, label) =>
              setState(() {
                _paymentMethod = method;
                _paymentLabel  = label;
              }),
            onAmountChanged: (val) =>
              _onAmountChanged(val, cart.total),
            onQuickAmount: _setQuickAmount,
            onPay: () => _onPay(cart),
            quickAmounts: _quickAmounts(cart.total),
          ),
    );
  }

  List<double> _quickAmounts(double total) {
    final rounded = (total / 10000).ceil() * 10000.0;
    final base = <double>[
      rounded,
      50000,
      100000,
      150000,
      200000,
      300000,
      500000,
    ];
    return base
      .where((a) => a >= total)
      .toSet()
      .toList()
      ..sort();
  }
}

// ═══════════════════════════════════════════════════
// WIDE LAYOUT (Tablet ≥ 800dp)
// ═══════════════════════════════════════════════════
class _WidePaymentLayout extends StatelessWidget {
  const _WidePaymentLayout({
    required this.cart,
    required this.trxState,
    required this.paymentMethod,
    required this.paymentLabel,
    required this.amountCtrl,
    required this.amountPaid,
    required this.change,
    required this.canPay,
    required this.nonCashOptions,
    required this.onMethodChanged,
    required this.onAmountChanged,
    required this.onQuickAmount,
    required this.onPay,
    required this.quickAmounts,
  });

  final CartStateModel cart;
  final TransactionState trxState;
  final String paymentMethod;
  final String paymentLabel;
  final TextEditingController amountCtrl;
  final double amountPaid;
  final double change;
  final bool canPay;
  final List<Map<String, String>> nonCashOptions;
  final void Function(String, String) onMethodChanged;
  final void Function(String) onAmountChanged;
  final void Function(double) onQuickAmount;
  final VoidCallback onPay;
  final List<double> quickAmounts;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── KIRI: Order Summary ────────────────
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: _OrderSummaryCard(cart: cart),
          ),
        ),

        const VerticalDivider(width: 1),

        // ── KANAN: Payment ─────────────────────
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                _PaymentMethodSection(
                  paymentMethod: paymentMethod,
                  paymentLabel: paymentLabel,
                  nonCashOptions: nonCashOptions,
                  onMethodChanged: onMethodChanged,
                ),

                const SizedBox(height: AppSizes.lg),

                if (paymentMethod == 'cash')
                  _CashInputSection(
                    amountCtrl: amountCtrl,
                    total: cart.total,
                    change: change,
                    onAmountChanged: onAmountChanged,
                    onQuickAmount: onQuickAmount,
                    quickAmounts: quickAmounts,
                  ),

                if (paymentMethod == 'non_cash')
                  _NonCashInfo(
                    label: paymentLabel,
                    total: cart.total,
                  ),

                const SizedBox(height: AppSizes.xl),

                _PayButton(
                  total: cart.total,
                  canPay: canPay,
                  isLoading: trxState.isLoading,
                  onPay: onPay,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// COMPACT LAYOUT (Phone < 800dp)
// ═══════════════════════════════════════════════════
class _CompactPaymentLayout extends StatelessWidget {
  const _CompactPaymentLayout({
    required this.cart,
    required this.trxState,
    required this.paymentMethod,
    required this.paymentLabel,
    required this.amountCtrl,
    required this.amountPaid,
    required this.change,
    required this.canPay,
    required this.nonCashOptions,
    required this.summaryExpanded,
    required this.onToggleSummary,
    required this.onMethodChanged,
    required this.onAmountChanged,
    required this.onQuickAmount,
    required this.onPay,
    required this.quickAmounts,
  });

  final CartStateModel cart;
  final TransactionState trxState;
  final String paymentMethod;
  final String paymentLabel;
  final TextEditingController amountCtrl;
  final double amountPaid;
  final double change;
  final bool canPay;
  final List<Map<String, String>> nonCashOptions;
  final bool summaryExpanded;
  final VoidCallback onToggleSummary;
  final void Function(String, String) onMethodChanged;
  final void Function(String) onAmountChanged;
  final void Function(double) onQuickAmount;
  final VoidCallback onPay;
  final List<double> quickAmounts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                // ── Collapsible Summary ─────────
                _CollapsibleSummary(
                  cart: cart,
                  isExpanded: summaryExpanded,
                  onToggle: onToggleSummary,
                ),

                const SizedBox(height: AppSizes.md),

                // ── Payment Method ──────────────
                _PaymentMethodSection(
                  paymentMethod: paymentMethod,
                  paymentLabel: paymentLabel,
                  nonCashOptions: nonCashOptions,
                  onMethodChanged: onMethodChanged,
                  compact: true,
                ),

                const SizedBox(height: AppSizes.md),

                // ── Cash Input ──────────────────
                if (paymentMethod == 'cash')
                  _CashInputSection(
                    amountCtrl: amountCtrl,
                    total: cart.total,
                    change: change,
                    onAmountChanged: onAmountChanged,
                    onQuickAmount: onQuickAmount,
                    quickAmounts: quickAmounts,
                    compact: true,
                  ),

                if (paymentMethod == 'non_cash')
                  _NonCashInfo(
                    label: paymentLabel,
                    total: cart.total,
                  ),
              ],
            ),
          ),
        ),

        // ── Sticky Bottom Pay Button ────────────
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Total
                Row(
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      CurrencyFormatter.format(cart.total),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                _PayButton(
                  total: cart.total,
                  canPay: canPay,
                  isLoading: trxState.isLoading,
                  onPay: onPay,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// SHARED COMPONENTS
// ═══════════════════════════════════════════════════

// ── ORDER SUMMARY CARD ────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.cart});
  final CartStateModel cart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.sm),
                Text(
                  'Ringkasan Pesanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),

            // Items
            ...cart.items.map((item) => _OrderItem(
              item: item,
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
    );
  }
}

// ── COLLAPSIBLE SUMMARY (Compact) ─────────────────
class _CollapsibleSummary extends StatelessWidget {
  const _CollapsibleSummary({
    required this.cart,
    required this.isExpanded,
    required this.onToggle,
  });

  final CartStateModel cart;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Header - always visible
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'Pesanan (${cart.totalItems} item)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.format(cart.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: AppSizes.xs),
                  Icon(
                    isExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Detail - expandable
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                children: [
                  ...cart.items.map((item) => _OrderItem(
                    item: item,
                    compact: true,
                  )),

                  if (cart.discountAmount > 0 ||
                      cart.taxAmount > 0 ||
                      cart.serviceAmount > 0) ...[
                    const Divider(),
                    _SummaryRow(
                      'Subtotal',
                      CurrencyFormatter.format(
                        cart.subtotal,
                      ),
                    ),
                    if (cart.discountAmount > 0)
                      _SummaryRow(
                        'Diskon',
                        '-${CurrencyFormatter.format(
                          cart.discountAmount,
                        )}',
                        color: AppColors.success,
                      ),
                    if (cart.taxAmount > 0)
                      _SummaryRow(
                        'Pajak',
                        CurrencyFormatter.format(
                          cart.taxAmount,
                        ),
                      ),
                    if (cart.serviceAmount > 0)
                      _SummaryRow(
                        'Service',
                        CurrencyFormatter.format(
                          cart.serviceAmount,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── ORDER ITEM ────────────────────────────────────
class _OrderItem extends StatelessWidget {
  const _OrderItem({
    required this.item,
    this.compact = false,
  });

  final CartItemModel item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? 4 : 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: compact ? 13 : 14,
                  ),
                ),
                if (item.addonNames.isNotEmpty)
                  Text(
                    '+ ${item.addonDisplay}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${item.qty}x',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            CurrencyFormatter.format(item.totalPrice),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: compact ? 13 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── PAYMENT METHOD SECTION ────────────────────────
class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({
    required this.paymentMethod,
    required this.paymentLabel,
    required this.nonCashOptions,
    required this.onMethodChanged,
    this.compact = false,
  });

  final String paymentMethod;
  final String paymentLabel;
  final List<Map<String, String>> nonCashOptions;
  final void Function(String, String) onMethodChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: [
            _PayMethodChip(
              icon: Icons.money,
              label: 'Cash',
              isSelected: paymentMethod == 'cash',
              onTap: () => onMethodChanged(
                'cash',
                'Cash',
              ),
              compact: compact,
            ),
            ...nonCashOptions.map((opt) =>
              _PayMethodChip(
                icon: _getIcon(opt['key']!),
                label: opt['label']!,
                isSelected: paymentLabel == opt['key'],
                onTap: () => onMethodChanged(
                  'non_cash',
                  opt['key']!,
                ),
                compact: compact,
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'QRIS':
        return Icons.qr_code;
      case 'Debit':
        return Icons.credit_card;
      case 'Transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}

class _PayMethodChip extends StatelessWidget {
  const _PayMethodChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSizes.md : AppSizes.lg,
          vertical: compact ? AppSizes.sm : AppSizes.md,
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
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary
                    .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                ? Colors.white
                : AppColors.textSecondary,
              size: compact ? 18 : 20,
            ),
            const SizedBox(width: AppSizes.xs),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                  ? Colors.white
                  : AppColors.textPrimary,
                fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
                fontSize: compact ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CASH INPUT SECTION ────────────────────────────
class _CashInputSection extends StatelessWidget {
  const _CashInputSection({
    required this.amountCtrl,
    required this.total,
    required this.change,
    required this.onAmountChanged,
    required this.onQuickAmount,
    required this.quickAmounts,
    this.compact = false,
  });

  final TextEditingController amountCtrl;
  final double total;
  final double change;
  final void Function(String) onAmountChanged;
  final void Function(double) onQuickAmount;
  final List<double> quickAmounts;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah Bayar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.sm),

        // Input
        TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: TextStyle(
            fontSize: compact ? 20 : 28,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: TextStyle(
              fontSize: compact ? 16 : 20,
              fontWeight: FontWeight.bold,
            ),
            hintText: '0',
          ),
          onChanged: onAmountChanged,
        ),

        const SizedBox(height: AppSizes.sm),

        // Quick amounts
        const Text(
          'Nominal Cepat:',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Wrap(
          spacing: AppSizes.xs,
          runSpacing: AppSizes.xs,
          children: quickAmounts.take(6).map((amt) =>
            ActionChip(
              label: Text(
                CurrencyFormatter.formatCompact(amt),
                style: TextStyle(
                  fontSize: compact ? 12 : 13,
                ),
              ),
              onPressed: () => onQuickAmount(amt),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 4 : 8,
              ),
            ),
          ).toList(),
        ),

        const SizedBox(height: AppSizes.md),

        // Kembalian
        _ChangeCard(change: change, compact: compact),
      ],
    );
  }
}

// ── CHANGE CARD ───────────────────────────────────
class _ChangeCard extends StatelessWidget {
  const _ChangeCard({
    required this.change,
    this.compact = false,
  });

  final double change;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isEnough = change >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isEnough
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
        border: Border.all(
          color: isEnough
            ? AppColors.success.withOpacity(0.3)
            : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isEnough
              ? Icons.check_circle_outline
              : Icons.warning_amber_outlined,
            color: isEnough
              ? AppColors.success
              : AppColors.error,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            'Kembalian',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: compact ? 14 : 16,
            ),
          ),
          const Spacer(),
          Text(
            isEnough
              ? CurrencyFormatter.format(change)
              : 'Kurang ${CurrencyFormatter.format(-change)}',
            style: TextStyle(
              color: isEnough
                ? AppColors.success
                : AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: compact ? 16 : 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ── NON-CASH INFO ─────────────────────────────────
class _NonCashInfo extends StatelessWidget {
  const _NonCashInfo({
    required this.label,
    required this.total,
  });

  final String label;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.info,
            size: 48,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Pembayaran via $label',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
          Text(
            CurrencyFormatter.format(total),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Pastikan pembayaran sudah diterima',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── PAY BUTTON ────────────────────────────────────
class _PayButton extends StatelessWidget {
  const _PayButton({
    required this.total,
    required this.canPay,
    required this.isLoading,
    required this.onPay,
  });

  final double total;
  final bool canPay;
  final bool isLoading;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canPay && !isLoading ? onPay : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSizes.radiusMd,
            ),
          ),
        ),
        child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 22),
                const SizedBox(width: AppSizes.sm),
                Text(
                  'BAYAR ${CurrencyFormatter.format(total)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

// ── SUMMARY ROW ───────────────────────────────────
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
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold
                ? FontWeight.bold
                : FontWeight.w500,
              color: color ?? AppColors.textPrimary,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}