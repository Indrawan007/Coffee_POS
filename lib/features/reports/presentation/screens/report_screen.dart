import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// Tambah di atas file
import 'dart:typed_data';
import 'package:printing/printing.dart';
import '../../../../core/utils/export_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/report_provider.dart';
import 'transaction_detail_screen.dart';

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(
              AppSizes.radiusMd,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppSizes.radiusMd,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: AppSizes.md),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVar,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Download Laporan',
            onSelected: (value) => _onExport(context, ref, value),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Export PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('Export Excel'),
                  ],
                ),
              ),
            ],
          ),
        ],
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

  // ✅ Method _showExportSuccess SEBELUM _onExport
  void _showExportSuccess(
    BuildContext context,
    ExportResult result,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    final content = _ExportSuccessContent(result: result);

    if (isWide) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSizes.radiusXl,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: content,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
        builder: (_) => content,
      );
    }
  }

  Future<void> _onExport(
    BuildContext context,
    WidgetRef ref,
    String type,
  ) async {
    final date = ref.read(selectedDateProvider);
    final dateStr = DateFormat('yyyyMMdd').format(date);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    // ✅ Responsive: Dialog di tablet, BottomSheet di HP
    final action = isWide
        ? await showDialog<String>(
            context: context,
            builder: (ctx) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.radiusXl,
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                ),
                child: _ExportSheet(
                  type: type,
                  date: date,
                  isDialog: true,
                ),
              ),
            ),
          )
        : await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusXl),
              ),
            ),
            builder: (ctx) => _ExportSheet(
              type: type,
              date: date,
              isDialog: false,
            ),
          );

    if (action == null || !context.mounted) return;

    // Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSizes.md),
                Text(
                  action == 'preview'
                      ? 'Membuat preview...'
                      : action == 'share'
                          ? 'Menyiapkan file...'
                          : 'Menyimpan file...',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final summary = await ref.read(
        reportSummaryProvider.future,
      );
      final best = await ref.read(
        reportBestSellerProvider.future,
      );
      final trx = await ref.read(
        reportTransactionsProvider.future,
      );
      final settings = ref.read(settingsStreamProvider).value;
      final export = ExportService.instance;

      // Preview
      if (action == 'preview' && type == 'pdf') {
        final bytes = await export.generatePdfBytes(
          date: date,
          summary: summary,
          bestSellers: best,
          transactions: trx,
          settings: settings,
        );
        if (context.mounted) Navigator.pop(context);
        if (context.mounted) {
          await Printing.layoutPdf(
            onLayout: (_) => bytes,
            name: 'Laporan_$dateStr',
          );
        }
        return;
      }

      // Generate bytes
      final fileName =
          type == 'pdf' ? 'Laporan_$dateStr.pdf' : 'Laporan_$dateStr.xlsx';

      Uint8List bytes;
      if (type == 'pdf') {
        bytes = await export.generatePdfBytes(
          date: date,
          summary: summary,
          bestSellers: best,
          transactions: trx,
          settings: settings,
        );
      } else {
        bytes = export.generateExcelBytes(
          date: date,
          summary: summary,
          bestSellers: best,
          transactions: trx,
          settings: settings,
        )!;
      }

      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;

      // Share
      if (action == 'share') {
        final result = await export.shareFile(
          fileName: fileName,
          bytes: bytes,
          mimeType: type == 'pdf'
              ? 'application/pdf'
              : 'application/vnd.openxmlformats-officedocument'
                  '.spreadsheetml.sheet',
        );
        if (!result.success && result.error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Save
      final result = await export.saveToDownloads(
        fileName: fileName,
        bytes: bytes,
      );

      if (!context.mounted) return;

      if (result.success) {
        _showExportSuccess(context, result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Gagal'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
                        : DateFormat('EEEE', 'id_ID').format(selectedDate),
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
        final totalTrx = _toInt(summary['total_trx']);
        final avgTrx = _toDouble(summary['avg_trx']);

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
          const Row(
            children: [
              Expanded(
                child: _MiniSummary(
                  icon: Icons.attach_money,
                  label: 'Omzet',
                  value: 'Rp 0',
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: _MiniSummary(
                  icon: Icons.receipt,
                  label: 'Transaksi',
                  value: '0x',
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSizes.sm),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  const _EmptySection(
                    icon: Icons.star_outline,
                    message: 'Belum ada produk terjual hari ini',
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
        final totalCash = _toDouble(summary['total_cash']);
        final totalNonCash = _toDouble(summary['total_non_cash']);
        final totalTrx = _toInt(summary['total_trx']);

        return Card(
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
                if (totalTrx == 0)
                  const _EmptySection(
                    icon: Icons.payment_outlined,
                    message: 'Belum ada pembayaran hari ini',
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
    final trxAsync = ref.watch(reportTransactionsProvider);

    return trxAsync.when(
      loading: () => const _ShimmerCard(),
      error: (e, _) => _ErrorCard(message: e.toString()),
      data: (transactions) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    message: 'Belum ada transaksi hari ini.\n'
                        'Buat transaksi pertama di menu Kasir.',
                    actionLabel: 'Buka Kasir',
                    onAction: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.pos);
                    },
                  )
                else
                  ...transactions.map(
                    (trx) => _TransactionTile(transaction: trx),
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
          trx.paymentMethod == 'cash' ? Icons.money : Icons.credit_card,
          color:
              trx.paymentMethod == 'cash' ? AppColors.success : AppColors.info,
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
      children: List.generate(
          3,
          (i) => Expanded(
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

class _ExportSheet extends StatelessWidget {
  const _ExportSheet({
    required this.type,
    required this.date,
    required this.isDialog,
  });

  final String type;
  final DateTime date;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    final isPdf = type == 'pdf';

    return Padding(
      padding: EdgeInsets.all(
        isDialog ? AppSizes.lg : AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle (hanya di bottom sheet)
          if (!isDialog)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(
                bottom: AppSizes.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // Close button (hanya di dialog)
          if (isDialog)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

          // ── HEADER ──────────────────────────
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isPdf
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.table_chart,
              color: isPdf ? Colors.red : Colors.green,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSizes.md),

          Text(
            isPdf ? 'Export Laporan PDF' : 'Export Laporan Excel',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.xs),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppSizes.radiusFull,
              ),
            ),
            child: Text(
              DateFormat('dd MMMM yyyy', 'id_ID').format(date),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          // ── OPSI ────────────────────────────
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pilih cara export:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // Simpan
          _ExportOption(
            icon: Icons.save_alt,
            iconColor: AppColors.success,
            label: 'Simpan ke Penyimpanan',
            subtitle: 'Folder CoffeePOS_Reports',
            onTap: () => Navigator.pop(context, 'save'),
          ),
          const SizedBox(height: AppSizes.sm),

          // Share
          _ExportOption(
            icon: Icons.share,
            iconColor: AppColors.info,
            label: 'Bagikan File',
            subtitle: 'WhatsApp, Email, Drive, dll',
            onTap: () => Navigator.pop(context, 'share'),
          ),

          // Preview (PDF only)
          if (isPdf) ...[
            const SizedBox(height: AppSizes.sm),
            _ExportOption(
              icon: Icons.visibility,
              iconColor: AppColors.primary,
              label: 'Preview & Print',
              subtitle: 'Lihat sebelum simpan / cetak',
              onTap: () => Navigator.pop(context, 'preview'),
            ),
          ],

          // ── INFO ────────────────────────────
          const SizedBox(height: AppSizes.md),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceVar,
              borderRadius: BorderRadius.circular(
                AppSizes.radiusSm,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: AppSizes.xs),
                Expanded(
                  child: Text(
                    isPdf
                        ? 'PDF cocok untuk dicetak atau dikirim ke owner'
                        : 'Excel cocok untuk analisis data lebih lanjut',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: isDialog ? AppSizes.sm : AppSizes.lg,
          ),
        ],
      ),
    );
  }
}

class _ExportSuccessContent extends StatelessWidget {
  const _ExportSuccessContent({required this.result});
  final ExportResult result;

  @override
  Widget build(BuildContext context) {
    final isPdf = result.fileName.endsWith('.pdf');

    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── SUCCESS ICON ──────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSizes.md),

          const Text(
            'Berhasil! 🎉',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Laporan berhasil disimpan',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          // ── FILE INFO ─────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVar,
              borderRadius: BorderRadius.circular(
                AppSizes.radiusMd,
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // File name
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isPdf
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSm,
                        ),
                      ),
                      child: Icon(
                        isPdf ? Icons.picture_as_pdf : Icons.table_chart,
                        color: isPdf ? Colors.red : Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        result.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.sm),

                // Path
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Expanded(
                      child: Text(
                        result.filePath,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          // ── BUTTONS ───────────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.check,
                      size: 18,
                    ),
                    label: const Text('Selesai'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ExportService.instance.openFile(result.filePath);
                    },
                    icon: const Icon(
                      Icons.open_in_new,
                      size: 18,
                    ),
                    label: const Text('Buka File'),
                    style: ElevatedButton.styleFrom(
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

          // Share button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ExportService.instance.shareFile(
                  fileName: result.fileName,
                  bytes: File(result.filePath).readAsBytesSync(),
                  mimeType: isPdf
                      ? 'application/pdf'
                      : 'application/vnd.openxmlformats-'
                          'officedocument.spreadsheetml.sheet',
                );
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Bagikan juga'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
