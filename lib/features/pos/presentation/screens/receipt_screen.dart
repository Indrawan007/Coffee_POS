import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/datasources/transaction_datasource.dart';
import '../../../settings/presentation/providers/printer_provider.dart';

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.result});
  final TransactionResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsStreamProvider);
    final trx   = result.transaction;
    final items = result.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaksi Berhasil'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.success,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            children: [
              // Success icon
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
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Receipt card
              settingsAsync.when(
                loading: () =>
                  const CircularProgressIndicator(),
                error: (e, _) =>
                  const SizedBox.shrink(),
                data: (settings) => Container(
                  constraints: const BoxConstraints(
                    maxWidth: 380,
                  ),
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
                      // Header toko
                      Container(
                        padding: const EdgeInsets.all(
                          AppSizes.md,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                              AppSizes.radiusLg,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              settings?.storeName ??
                                'Coffee Shop',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (settings?.storeAddress !=
                                null)
                              Text(
                                settings!.storeAddress!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            if (settings?.storePhone !=
                                null)
                              Text(
                                settings!.storePhone!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(
                          AppSizes.md,
                        ),
                        child: Column(
                          children: [
                            // Invoice info
                            _ReceiptRow(
                              'No Invoice',
                              trx.invoiceNumber,
                              isBold: true,
                            ),
                            _ReceiptRow(
                              'Kasir',
                              trx.cashierName,
                            ),
                            _ReceiptRow(
                              'Tanggal',
                              DateFormatter.toDisplayWithTime(
                                DateTime.parse(trx.createdAt),
                              ),
                            ),

                            const Divider(height: AppSizes.lg),

                            // Items
                            ...items.map((item) => Padding(
                              padding:
                                const EdgeInsets.only(
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
                                            fontWeight:
                                              FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${item.qty}x',
                                        style: const TextStyle(
                                          color: AppColors
                                            .textSecondary,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: AppSizes.sm,
                                      ),
                                      Text(
                                        CurrencyFormatter
                                          .format(item.total),
                                        style: const TextStyle(
                                          fontWeight:
                                            FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.addonNamesSnapshot !=
                                      null)
                                    Text(
                                      '+ ${item.addonNamesSnapshot}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors
                                          .textSecondary,
                                      ),
                                    ),
                                  if (item.note != null)
                                    Text(
                                      '📝 ${item.note}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontStyle:
                                          FontStyle.italic,
                                        color: AppColors
                                          .textHint,
                                      ),
                                    ),
                                ],
                              ),
                            )),

                            const Divider(height: AppSizes.lg),

                            // Totals
                            _ReceiptRow(
                              'Subtotal',
                              CurrencyFormatter.format(
                                trx.subtotal,
                              ),
                            ),
                            if (trx.discountAmount > 0)
                              _ReceiptRow(
                                'Diskon',
                                '-${CurrencyFormatter.format(trx.discountAmount)}',
                                valueColor: AppColors.success,
                              ),
                            if (trx.taxAmount > 0)
                              _ReceiptRow(
                                'Pajak',
                                CurrencyFormatter.format(
                                  trx.taxAmount,
                                ),
                              ),
                            if (trx.serviceAmount > 0)
                              _ReceiptRow(
                                'Service',
                                CurrencyFormatter.format(
                                  trx.serviceAmount,
                                ),
                              ),

                            const Divider(),

                            _ReceiptRow(
                              'TOTAL',
                              CurrencyFormatter.format(
                                trx.total,
                              ),
                              isBold: true,
                              fontSize: 18,
                            ),
                            _ReceiptRow(
                              trx.paymentLabel ?? trx.paymentMethod,
                              CurrencyFormatter.format(
                                trx.amountPaid,
                              ),
                            ),
                            if (trx.changeAmount > 0)
                              _ReceiptRow(
                                'Kembalian',
                                CurrencyFormatter.format(
                                  trx.changeAmount,
                                ),
                                valueColor: AppColors.success,
                              ),

                            const SizedBox(height: AppSizes.md),

                            // Footer
                            Text(
                              settings?.storeFooter ??
                                'Terima kasih!',
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
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // Action buttons
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 380,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Print – Sprint 3
                          ScaffoldMessenger.of(context)
                            .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur cetak tersedia di Sprint 3',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Cetak Struk'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                          context.go(AppRoutes.pos),
                        icon: const Icon(Icons.add),
                        label: const Text('Transaksi Baru'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}

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
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: fontSize,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold
                ? FontWeight.bold
                : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// Ganti tombol Cetak Struk menjadi:
class _PrintButton extends ConsumerWidget {
  const _PrintButton({required this.result});
  final TransactionResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerState   = ref.watch(printerNotifierProvider);
    final settingsAsync  = ref.watch(settingsStreamProvider);

    ref.listen(printerNotifierProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return OutlinedButton.icon(
      onPressed: printerState.isPrinting
        ? null
        : () {
            final settings = settingsAsync.value;
            ref
              .read(printerNotifierProvider.notifier)
              .printReceipt(
                transaction: result.transaction,
                items: result.items,
                settings: settings,
              );
          },
      icon: printerState.isPrinting
        ? const SizedBox(
            width: 16,
            height: 16,
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
    );
  }
}
