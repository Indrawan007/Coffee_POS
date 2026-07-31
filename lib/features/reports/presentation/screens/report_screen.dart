import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/router/app_router.dart';
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _DatePickerBar(selectedDate: selectedDate),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(reportSummaryProvider);
                ref.invalidate(reportTransactionsProvider);
                ref.invalidate(reportBestSellerProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: const [
                  _SummarySection(),
                  SizedBox(height: AppSizes.md),
                  _BestSellerSection(),
                  SizedBox(height: AppSizes.md),
                  _PaymentBreakdownSection(),
                  SizedBox(height: AppSizes.md),
                  _TransactionListSection(),
                  SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// DATE PICKER BAR
// ═══════════════════════════════════════════════════
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
              selectedDate.subtract(
                const Duration(days: 1),
              ),
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
                if (picked != null) {
                  notifier.setDate(picked);
                }
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
                  selectedDate.add(
                    const Duration(days: 1),
                  ),
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

// ═══════════════════════════════════════════════════
// SUMMARY SECTION
// ═══════════════════════════════════════════════════
class _SummarySection extends ConsumerWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportSummaryProvider);

    return summaryAsync.when(
      loading: () => const _ShimmerCards(),
      error: (e, _) => _ErrorCard(message: e.toString()),
      data: (summary) {
        final totalRevenue = _toDouble(summary['total_revenue']);
        final totalTrx     = _toInt(summary['total_trx']);
        final avgTrx       = _toDouble(summary['avg_trx']);

        // ✅ Jika semua data 0 → tampilkan empty state
        if (totalTrx == 0) {
          return _EmptyDayCard();
        }

        return Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Total Omzet',
                value: CurrencyFormatter.format(
                  totalRevenue,
                ),
                icon: Icons.attach_money,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _SummaryCard(
                label: 'Transaksi',
                value: '${totalTrx}x',
                icon: Icons.receipt,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _SummaryCard(
                label: 'Rata-rata',
                value: CurrencyFormatter.formatCompact(
                  avgTrx,
                ),
                icon: Icons.trending_up,
                color: AppColors.accent,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ✅ EMPTY DAY CARD
class _EmptyDayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppSizes.radiusLg,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.coffee_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Belum Ada Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Belum ada penjualan pada tanggal ini.\n'
            'Mulai transaksi pertama Anda! ☕',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Summary cards showing 0
          Row(
            children: [
              Expanded(
                child: _MiniSummary(
                  icon: Icons.attach_money,
                  label: 'Omzet',
                  value: 'Rp 0',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _MiniSummary(
                  icon: Icons.receipt,
                  label: 'Transaksi',
                  value: '0x',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _MiniSummary(
                  icon: Icons.trending_up,
                  label: 'Rata-rata',
                  value: 'Rp 0',
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

class _MiniSummary extends StatelessWidget {
  const _MiniSummary({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(
          AppSizes.radiusSm,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.5),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
            ),
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
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

// ═══════════════════════════════════════════════════
// BEST SELLER SECTION
// ═══════════════════════════════════════════════════
class _BestSellerSection extends ConsumerWidget {
  const _BestSellerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestAsync = ref.watch(reportBestSellerProvider);

    return bestAsync.when(
      loading: () => const _ShimmerCard(),
      error: (e, _) => const SizedBox.shrink(),
      data: (items) {
        // ✅ Jika kosong → card dengan empty state
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.accent,
                    ),
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

                if (items.isEmpty)
                  _EmptySection(
                    icon: Icons.star_outline,
                    message:
                      'Belum ada produk terjual hari ini',
                  )
                else
                  ...items.asMap().entries.map((e) {
                    final rank = e.key + 1;
                    final item = e.value;
                    return _BestSellerItem(
                      rank: rank,
                      name: item['name'] ?? '-',
                      qty: _toInt(item['qty']),
                      revenue: _toDouble(item['revenue']),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BestSellerItem extends StatelessWidget {
  const _BestSellerItem({
    required this.rank,
    required this.name,
    required this.qty,
    required this.revenue,
  });

  final int rank;
  final String name;
  final int qty;
  final double revenue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: rank == 1
          ? AppColors.accent
          : rank == 2
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.border,
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: rank == 1
              ? Colors.white
              : rank == 2
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        '$qty porsi',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        CurrencyFormatter.format(revenue),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// PAYMENT BREAKDOWN SECTION
// ═══════════════════════════════════════════════════
class _PaymentBreakdownSection extends ConsumerWidget {
  const _PaymentBreakdownSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportSummaryProvider);

    return summaryAsync.when(
      loading: () => const _ShimmerCard(),
      error: (e, _) => const SizedBox.shrink(),
      data: (summary) {
        final totalCash    = _toDouble(summary['total_cash']);
        final totalNonCash = _toDouble(summary['total_non_cash']);
        final totalTrx     = _toInt(summary['total_trx']);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
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

                if (totalTrx == 0)
                  _EmptySection(
                    icon: Icons.payment_outlined,
                    message:
                      'Belum ada pembayaran hari ini',
                  )
                else ...[
                  _PaymentBar(
                    method: '💵 Cash',
                    amount: totalCash,
                    total: totalCash + totalNonCash,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  _PaymentBar(
                    method: '📱 Non-Cash',
                    amount: totalNonCash,
                    total: totalCash + totalNonCash,
                    color: AppColors.info,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaymentBar extends StatelessWidget {
  const _PaymentBar({
    required this.method,
    required this.amount,
    required this.total,
    required this.color,
  });

  final String method;
  final double amount;
  final double total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? amount / total : 0.0;

    return Column(
      children: [
        Row(
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
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// TRANSACTION LIST SECTION
// ═══════════════════════════════════════════════════
class _TransactionListSection extends ConsumerWidget {
  const _TransactionListSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trxAsync =
      ref.watch(reportTransactionsProvider);

    return trxAsync.when(
      loading: () => const _ShimmerCard(),
      error: (e, _) => _ErrorCard(message: e.toString()),
      data: (transactions) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.list_alt,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    const Text(
                      'Riwayat Transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (transactions.isNotEmpty)
                      Text(
                        '${transactions.length} transaksi',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const Divider(),

                // ✅ Empty state
                if (transactions.isEmpty)
                  _EmptySection(
                    icon: Icons.receipt_long_outlined,
                    message:
                      'Belum ada transaksi hari ini.\n'
                      'Buat transaksi pertama di menu Kasir.',
                    actionLabel: 'Buka Kasir',
                    onAction: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.pos);
                    },
                  )
                else
                  ...transactions.map((trx) =>
                    _TransactionTile(transaction: trx),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});
  final TransactionsTableData transaction;

  @override
  Widget build(BuildContext context) {
    final trx  = transaction;
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

// ═══════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════

// ✅ REUSABLE EMPTY SECTION
class _EmptySection extends StatelessWidget {
  const _EmptySection({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.lg,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: AppSizes.md),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(
                  Icons.point_of_sale,
                  size: 18,
                ),
                label: Text(actionLabel ?? 'Action'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                    color: AppColors.primary,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ✅ SHIMMER LOADING CARDS
class _ShimmerCards extends StatelessWidget {
  const _ShimmerCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(
            right: i < 2 ? AppSizes.sm : 0,
          ),
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(
              AppSizes.radiusMd,
            ),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      )),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(AppSizes.md),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
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
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Tambahkan helper function di bagian paling bawah file

// ── SAFE TYPE CONVERSION ──────────────────────────
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}