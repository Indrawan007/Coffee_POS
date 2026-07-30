import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../pos/data/datasources/transaction_datasource.dart';
import '../../../pos/presentation/providers/transaction_provider.dart';
import '../../../settings/presentation/providers/printer_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });
  final TransactionsTableData transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trx          = transaction;
    final settingsAsync = ref.watch(settingsStreamProvider);
    final printerState = ref.watch(printerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(trx.invoiceNumber),
        actions: [
          // Cetak ulang
          IconButton(
            icon: printerState.isPrinting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.print),
            tooltip: 'Cetak Ulang',
            onPressed: printerState.isPrinting
              ? null
              : () async {
                  final items = await ref
                    .read(transactionDatasourceProvider)
                    .getItemsByTransaction(trx.id);

                  final settings = settingsAsync.value;

                  ref
                    .read(printerNotifierProvider.notifier)
                    .printReceipt(
                      transaction: trx,
                      items: items,
                      settings: settings,
                    );
                },
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionItemsTableData>>(
        future: ref
          .read(transactionDatasourceProvider)
          .getItemsByTransaction(trx.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final items = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                // ── INFO CARD ──────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment:
                        CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          'No Invoice',
                          trx.invoiceNumber,
                          isBold: true,
                        ),
                        _InfoRow('Kasir', trx.cashierName),
                        _InfoRow(
                          'Tanggal',
                          DateFormatter.toDisplayWithTime(
                            DateTime.parse(trx.createdAt),
                          ),
                        ),
                        _InfoRow(
                          'Metode Bayar',
                          trx.paymentLabel ??
                            trx.paymentMethod,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // ── ITEMS ──────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment:
                        CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Item Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const Divider(),

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
                                        fontWeight:
                                          FontWeight.w600,
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
                                  const SizedBox(width: 8),
                                  Text(
                                    CurrencyFormatter.format(
                                      item.total,
                                    ),
                                    style: const TextStyle(
                                      fontWeight:
                                        FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.addonNamesSnapshot
                                  != null)
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
                                    color: AppColors.textHint,
                                  ),
                                ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // ── SUMMARY ────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      children: [
                        _InfoRow(
                          'Subtotal',
                          CurrencyFormatter.format(
                            trx.subtotal,
                          ),
                        ),
                        if (trx.discountAmount > 0)
                          _InfoRow(
                            'Diskon',
                            '-${CurrencyFormatter.format(trx.discountAmount)}',
                            valueColor: AppColors.success,
                          ),
                        if (trx.taxAmount > 0)
                          _InfoRow(
                            'Pajak (${trx.taxPercent.toInt()}%)',
                            CurrencyFormatter.format(
                              trx.taxAmount,
                            ),
                          ),
                        if (trx.serviceAmount > 0)
                          _InfoRow(
                            'Service (${trx.servicePercent.toInt()}%)',
                            CurrencyFormatter.format(
                              trx.serviceAmount,
                            ),
                          ),
                        const Divider(),
                        _InfoRow(
                          'TOTAL',
                          CurrencyFormatter.format(trx.total),
                          isBold: true,
                          fontSize: 18,
                        ),
                        _InfoRow(
                          trx.paymentLabel ??
                            trx.paymentMethod,
                          CurrencyFormatter.format(
                            trx.amountPaid,
                          ),
                        ),
                        if (trx.changeAmount > 0)
                          _InfoRow(
                            'Kembalian',
                            CurrencyFormatter.format(
                              trx.changeAmount,
                            ),
                            valueColor: AppColors.success,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
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
            style: const TextStyle(
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
              color: valueColor ?? AppColors.textPrimary,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}