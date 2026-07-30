import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/report_provider.dart';
import 'transaction_detail_screen.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Column(
        children: [
          // ── DATE PICKER ──────────────────────
          _DatePickerBar(selectedDate: selectedDate),

          // ── CONTENT ──────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(reportSummaryProvider);
                ref.invalidate(reportTransactionsProvider);
                ref.invalidate(reportBestSellerProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  // Summary cards
                  _SummarySection(),
                  const SizedBox(height: AppSizes.md),

                  // Best seller
                  _BestSellerSection(),
                  const SizedBox(height: AppSizes.md),

                  // Payment breakdown
                  _PaymentBreakdownSection(),
                  const SizedBox(height: AppSizes.md),

                  // Transaction list
                  _TransactionListSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DATE PICKER BAR ──────────────────────────────
class _DatePickerBar extends ConsumerWidget {
  const _DatePickerBar({required this.selectedDate});
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(selectedDateProvider.notifier);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => notifier.setDate(
              selectedDate.subtract(const Duration(days: 1)),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) notifier.setDate(picked);
              },
              child: Column(
                children: [
                  Text(
                    DateFormatter.toDisplay(selectedDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _isToday(selectedDate)
                      ? 'Hari ini'
                      : DateFormat('EEEE', 'id_ID')
                          .format(selectedDate),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _isToday(selectedDate)
              ? null
              : () => notifier.setDate(
                  selectedDate.add(const Duration(days: 1)),
                ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
  }
}

// ─── SUMMARY SECTION ──────────────────────────────
class _SummarySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportSummaryProvider);

    return summaryAsync.when(
      loading: () => const _LoadingCard(),
      error: (e, _) => _ErrorCard(message: e.toString()),
      data: (summary) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Omzet',
                  value: CurrencyFormatter.format(
                    summary['total_revenue'] ?? 0,
                  ),
                  icon: Icons.attach_money,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _SummaryCard(
                  label: 'Transaksi',
                  value: '${summary['total_trx'] ?? 0}x',
                  icon: Icons.receipt,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _SummaryCard(
                  label: 'Rata-rata',
                  value: CurrencyFormatter.formatCompact(
                    summary['avg_trx'] ?? 0,
                  ),
                  icon: Icons.trending_up,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BEST SELLER SECTION ──────────────────────────
class _BestSellerSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestAsync = ref.watch(reportBestSellerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: AppColors.accent),
                SizedBox(width: AppSizes.sm),
                Text(
                  'Produk Terlaris',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Divider(),

            bestAsync.when(
              loading: () => const _LoadingCard(),
              error: (e, _) => Text('Error: $e'),
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSizes.md),
                    child: Text(
                      'Belum ada data',
                      style: TextStyle(
                        color: AppColors.textHint,
                      ),
                    ),
                  );
                }

                return Column(
                  children: items.asMap().entries.map((e) {
                    final rank = e.key + 1;
                    final item = e.value;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: rank == 1
                          ? AppColors.accent
                          : AppColors.primary
                              .withOpacity(0.1),
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: rank == 1
                              ? Colors.white
                              : AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(item['name'] ?? '-'),
                      subtitle: Text(
                        '${item['qty']} porsi',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      trailing: Text(
                        CurrencyFormatter.format(
                          item['revenue'] ?? 0,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PAYMENT BREAKDOWN ────────────────────────────
class _PaymentBreakdownSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportSummaryProvider);

    return summaryAsync.when(
      loading: () => const _LoadingCard(),
      error: (e, _) => const SizedBox.shrink(),
      data: (summary) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.payment,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSizes.sm),
                  Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const Divider(),

              _PaymentRow(
                method: '💵 Cash',
                amount: summary['total_cash'] ?? 0,
                color: AppColors.success,
              ),
              _PaymentRow(
                method: '📱 Non-Cash',
                amount: summary['total_non_cash'] ?? 0,
                color: AppColors.info,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.method,
    required this.amount,
    required this.color,
  });

  final String method;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.xs,
      ),
      child: Row(
        children: [
          Text(method),
          const Spacer(),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TRANSACTION LIST ─────────────────────────────
class _TransactionListSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trxAsync = ref.watch(reportTransactionsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.sm),
                Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Divider(),

            trxAsync.when(
              loading: () => const _LoadingCard(),
              error: (e, _) => Text('Error: $e'),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSizes.lg),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                          SizedBox(height: AppSizes.sm),
                          Text(
                            'Tidak ada transaksi',
                            style: TextStyle(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: transactions.map((trx) =>
                    _TransactionTile(transaction: trx),
                  ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});
  final TransactionsTableData transaction;

  @override
  Widget build(BuildContext context) {
    final trx = transaction;
    final time = DateFormatter.toTimeOnly(
      DateTime.parse(trx.createdAt),
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: trx.paymentMethod == 'cash'
            ? AppColors.success.withOpacity(0.1)
            : AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(
            AppSizes.radiusSm,
          ),
        ),
        child: Icon(
          trx.paymentMethod == 'cash'
            ? Icons.money
            : Icons.credit_card,
          color: trx.paymentMethod == 'cash'
            ? AppColors.success
            : AppColors.info,
          size: 20,
        ),
      ),
      title: Text(
        trx.invoiceNumber,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        '$time • ${trx.cashierName} • '
        '${trx.paymentLabel ?? trx.paymentMethod}',
        style: const TextStyle(fontSize: 11),
      ),
      trailing: Text(
        CurrencyFormatter.format(trx.total),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(
            transaction: trx,
          ),
        ),
      ),
    );
  }
}

// ─── HELPERS ──────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSizes.lg),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Text(
        'Error: $message',
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }
}