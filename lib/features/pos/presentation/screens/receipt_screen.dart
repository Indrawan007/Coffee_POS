import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:coffee_pos/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/printer_service.dart';
import '../../../settings/presentation/providers/printer_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/datasources/transaction_datasource.dart';

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.result});
  final TransactionResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsStreamProvider);
    final trx   = result.transaction;
    final items = result.items;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide      = screenWidth >= 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goToPos(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Transaksi Berhasil'),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.success,
          actions: [
            // Close button
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _goToPos(context),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                // ── SUCCESS HEADER ─────────────
                _SuccessHeader(),
                const SizedBox(height: AppSizes.lg),

                // ── RECEIPT CARD ───────────────
                settingsAsync.when(
                  loading: () =>
                    const CircularProgressIndicator(),
                  error: (e, _) =>
                    const SizedBox.shrink(),
                  data: (settings) => Container(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 420 : double.infinity,
                    ),
                    child: _ReceiptCard(
                      trx: trx,
                      items: items,
                      settings: settings,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                // ── ACTION BUTTONS ─────────────
                Container(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 420 : double.infinity,
                  ),
                  child: _ActionButtons(
                    result: result,
                  ),
                ),

                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToPos(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    context.push(AppRoutes.pos);
  }
}

// ═══════════════════════════════════════════════════
// SUCCESS HEADER
// ═══════════════════════════════════════════════════
class _SuccessHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 64,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        const Text(
          'Pembayaran Berhasil! 🎉',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// RECEIPT CARD
// ═══════════════════════════════════════════════════
class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.trx,
    required this.items,
    required this.settings,
  });

  final TransactionsTableData trx;
  final List<TransactionItemsTableData> items;
  final SettingsTableData? settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppSizes.radiusLg,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // ── STORE HEADER ──────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusLg),
              ),
            ),
            child: Column(
              children: [
                Text(
                  settings?.storeName ?? 'Coffee Shop',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (settings?.storeAddress != null)
                  Text(
                    settings!.storeAddress!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (settings?.storePhone != null)
                  Text(
                    settings!.storePhone!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),

          // ── RECEIPT BODY ──────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                // Invoice info
                _ReceiptRow(
                  'No Invoice',
                  trx.invoiceNumber,
                  isBold: true,
                ),
                _ReceiptRow('Kasir', trx.cashierName),
                _ReceiptRow(
                  'Tanggal',
                  DateFormatter.toDisplayWithTime(
                    DateTime.parse(trx.createdAt),
                  ),
                ),

                const Divider(height: AppSizes.lg),

                // Items
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSizes.sm,
                  ),
                  child: Column(
                    crossAxisAlignment:
                      CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productNameSnapshot}'
                              '${item.variantNameSnapshot != null
                                ? ' (${item.variantNameSnapshot})'
                                : ''
                              }',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${item.qty}x',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            CurrencyFormatter.format(
                              item.total,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (item.addonNamesSnapshot != null)
                        Text(
                          '+ ${item.addonNamesSnapshot}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      if (item.note != null)
                        Text(
                          '📝 ${item.note}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                )),

                const Divider(height: AppSizes.lg),

                // Totals
                _ReceiptRow(
                  'Subtotal',
                  CurrencyFormatter.format(trx.subtotal),
                ),
                if (trx.discountAmount > 0)
                  _ReceiptRow(
                    'Diskon',
                    '-${CurrencyFormatter.format(
                      trx.discountAmount,
                    )}',
                    valueColor: AppColors.success,
                  ),
                if (trx.taxAmount > 0)
                  _ReceiptRow(
                    'Pajak (${trx.taxPercent.toInt()}%)',
                    CurrencyFormatter.format(trx.taxAmount),
                  ),
                if (trx.serviceAmount > 0)
                  _ReceiptRow(
                    'Service (${trx.servicePercent.toInt()}%)',
                    CurrencyFormatter.format(
                      trx.serviceAmount,
                    ),
                  ),

                const Divider(),

                _ReceiptRow(
                  'TOTAL',
                  CurrencyFormatter.format(trx.total),
                  isBold: true,
                  fontSize: 20,
                ),
                _ReceiptRow(
                  trx.paymentLabel ?? trx.paymentMethod,
                  CurrencyFormatter.format(trx.amountPaid),
                ),
                if (trx.changeAmount > 0)
                  _ReceiptRow(
                    'Kembalian',
                    CurrencyFormatter.format(
                      trx.changeAmount,
                    ),
                    valueColor: AppColors.success,
                    isBold: true,
                  ),

                const SizedBox(height: AppSizes.md),

                // Footer
                Text(
                  settings?.storeFooter ??
                    'Terima kasih atas kunjungan Anda!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ACTION BUTTONS
// ═══════════════════════════════════════════════════
class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.result});
  final TransactionResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerState  = ref.watch(printerNotifierProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);

    // ✅ Listen printer messages
    ref.listen(printerNotifierProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Column(
      children: [
        // ── ROW 1: Cetak & Transaksi Baru ──────
        Row(
          children: [
            // Cetak Struk
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: printerState.isPrinting
                    ? null
                    : () => _onPrint(context, ref),
                  icon: printerState.isPrinting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.print),
                  label: Text(
                    printerState.isPrinting
                      ? 'Mencetak...'
                      : 'Cetak Struk',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMd,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSizes.md),

            // Transaksi Baru
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _goToNewTransaction(
                    context,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Transaksi Baru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMd,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.sm),

        // ── ROW 2: Kembali ke Dashboard ────────
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context)
                .popUntil((route) => route.isFirst);
            },
            icon: const Icon(
              Icons.home_outlined,
              size: 20,
            ),
            label: const Text('Kembali ke Dashboard'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ),

        // ── Printer Status ─────────────────────
        if (!printerState.isConnected)
          Container(
            margin: const EdgeInsets.only(
              top: AppSizes.sm,
            ),
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppSizes.radiusSm,
              ),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: 16,
                ),
                const SizedBox(width: AppSizes.xs),
                const Expanded(
                  child: Text(
                    'Printer belum terhubung. '
                    'Hubungkan di menu Pengaturan > Printer.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    context.push('/settings/printer');
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                    ),
                    tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Setup',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ✅ PRINT FUNCTION
  void _onPrint(BuildContext context, WidgetRef ref) async {
    final printerState = ref.read(printerNotifierProvider);

    // Cek apakah printer terhubung
    if (!printerState.isConnected) {
      // Tampilkan dialog pilihan
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Printer Belum Terhubung'),
          content: const Text(
            'Hubungkan printer Bluetooth terlebih dahulu '
            'untuk mencetak struk.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                Navigator.pop(ctx, 'cancel'),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () =>
                Navigator.pop(ctx, 'setup'),
              child: const Text('Setup Printer'),
            ),
          ],
        ),
      );

      if (action == 'setup' && context.mounted) {
        Navigator.of(context)
          .popUntil((route) => route.isFirst);
        context.push('/settings/printer');
      }
      return;
    }

    // Printer terhubung → cetak
    final settingsAsync = ref.read(settingsStreamProvider);
    final settings = settingsAsync.value;

    ref.read(printerNotifierProvider.notifier).printReceipt(
      transaction: result.transaction,
      items: result.items,
      settings: settings,
    );
  }

  // ✅ NEW TRANSACTION FUNCTION
  void _goToNewTransaction(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    context.push(AppRoutes.pos);
  }
}

// ═══════════════════════════════════════════════════
// RECEIPT ROW
// ═══════════════════════════════════════════════════
class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.valueColor,
    this.fontSize = 14,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: fontSize,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold
                  ? FontWeight.bold
                  : FontWeight.w500,
                color:
                  valueColor ?? AppColors.textPrimary,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}