import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


import '../../../../core/utils/backup_service.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../providers/backup_provider.dart';

class BackupRestoreScreen extends ConsumerWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(backupNotifierProvider);
    final notifier = ref.read(backupNotifierProvider.notifier);

    // Listen messages
    ref.listen(backupNotifierProvider, (prev, next) {
      if (next.message != null &&
          next.message != prev?.message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message!),
            backgroundColor: next.isError
              ? AppColors.error
              : AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Clear message after show
        Future.delayed(
          const Duration(seconds: 1),
          notifier.clearMessage,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: notifier.loadData,
          ),
        ],
      ),
      body: state.isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: notifier.loadData,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                // ── DB INFO ───────────────────
                _DatabaseInfoCard(dbInfo: state.dbInfo),
                const SizedBox(height: AppSizes.md),

                // ── BACKUP BUTTON ─────────────
                _BackupActionCard(
                  isLoading: state.isLoading,
                  lastBackup: state.lastBackup,
                  backupPath: state.backupPath,
                  onBackup: notifier.createBackup,
                ),
                const SizedBox(height: AppSizes.md),

                // ── BACKUP LIST ───────────────
                _BackupListCard(
                  backups: state.backups,
                  onRestore: (path) =>
                    _onRestore(context, ref, path),
                  onDelete: (path) =>
                    _onDelete(context, ref, path),
                ),
                const SizedBox(height: AppSizes.md),

                // ── TIPS ──────────────────────
                const _TipsCard(),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
    );
  }

  Future<void> _onRestore(
    BuildContext context,
    WidgetRef ref,
    String path,
  ) async {
    final confirm = await AppDialog.confirm(
      context,
      title: '⚠️ Restore Data',
      message:
        'Data saat ini akan DIGANTI dengan data backup.\n\n'
        'Pastikan Anda sudah backup data terbaru.\n\n'
        'Aplikasi akan di-restart setelah restore.\n\n'
        'Lanjutkan?',
      confirmLabel: 'Ya, Restore',
      confirmColor: AppColors.warning,
    );

    if (confirm != true) return;

    // Konfirmasi kedua
    final confirm2 = await AppDialog.confirm(
      context,
      title: 'Konfirmasi Final',
      message:
        'Anda YAKIN ingin mengganti semua data?',
      confirmLabel: 'Restore Sekarang',
      confirmColor: AppColors.error,
    );

    if (confirm2 != true) return;

    final success = await ref
      .read(backupNotifierProvider.notifier)
      .restoreBackup(path);

    if (success && context.mounted) {
      // Show restart dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
              ),
              SizedBox(width: AppSizes.sm),
              Text('Restore Berhasil'),
            ],
          ),
          content: const Text(
            'Data berhasil di-restore.\n\n'
            'Tutup dan buka ulang aplikasi '
            'agar perubahan diterapkan.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Close semua dan keluar
                Navigator.of(context)
                  .popUntil((route) => route.isFirst);
              },
              child: const Text('OK, Mengerti'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _onDelete(
    BuildContext context,
    WidgetRef ref,
    String path,
  ) async {
    final confirm = await AppDialog.confirm(
      context,
      title: 'Hapus Backup',
      message: 'Hapus file backup ini?',
      confirmLabel: 'Hapus',
      confirmColor: AppColors.error,
    );

    if (confirm == true) {
      ref
        .read(backupNotifierProvider.notifier)
        .deleteBackup(path);
    }
  }
}

// ═══════════════════════════════════════════════════
// DATABASE INFO CARD
// ═══════════════════════════════════════════════════
class _DatabaseInfoCard extends StatelessWidget {
  const _DatabaseInfoCard({this.dbInfo});
  final Map<String, dynamic>? dbInfo;

  @override
  Widget build(BuildContext context) {
    final exists   = dbInfo?['exists'] ?? false;
    final size     = dbInfo?['size'] ?? 0;
    final modified = dbInfo?['modified'];

    String sizeStr = '$size B';
    if (size is int) {
      if (size >= 1024 * 1024) {
        sizeStr =
          '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else if (size >= 1024) {
        sizeStr =
          '${(size / 1024).toStringAsFixed(1)} KB';
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.storage,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.sm),
                Text(
                  'Informasi Database',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Divider(),
            _InfoRow(
              'Status',
              exists ? '● Aktif' : '● Tidak ditemukan',
              valueColor: exists
                ? AppColors.success
                : AppColors.error,
            ),
            if (exists) ...[
              _InfoRow('Ukuran', sizeStr),
              if (modified != null)
                _InfoRow(
                  'Terakhir diubah',
                  DateFormat('dd/MM/yyyy HH:mm')
                    .format(modified as DateTime),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// BACKUP ACTION CARD
// ═══════════════════════════════════════════════════
class _BackupActionCard extends StatelessWidget {
  const _BackupActionCard({
    required this.isLoading,
    required this.lastBackup,
    required this.backupPath,
    required this.onBackup,
  });

  final bool isLoading;
  final BackupInfo? lastBackup;
  final String? backupPath;
  final VoidCallback onBackup;

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
                  Icons.backup,
                  color: AppColors.success,
                ),
                SizedBox(width: AppSizes.sm),
                Text(
                  'Backup Data',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Divider(),

            const Text(
              'Backup menyimpan semua data ke penyimpanan lokal.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),

            if (backupPath != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                '📁 $backupPath',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (lastBackup != null) ...[
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppSizes.radiusSm,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Expanded(
                      child: Text(
                        'Backup terakhir: '
                        '${lastBackup!.fileName}\n'
                        '${lastBackup!.fileSizeFormatted}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSizes.md),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onBackup,
                icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.backup),
                label: Text(
                  isLoading
                    ? 'Membuat backup...'
                    : 'Buat Backup Sekarang',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// BACKUP LIST CARD
// ═══════════════════════════════════════════════════
class _BackupListCard extends StatelessWidget {
  const _BackupListCard({
    required this.backups,
    required this.onRestore,
    required this.onDelete,
  });

  final List<BackupInfo> backups;
  final void Function(String) onRestore;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restore,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSizes.sm),
                const Text(
                  'Riwayat Backup',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  '${backups.length} file',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Divider(),

            if (backups.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.lg,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: AppSizes.sm),
                      Text(
                        'Belum ada backup',
                        style: TextStyle(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...backups.map((backup) => _BackupTile(
                backup: backup,
                onRestore: () =>
                  onRestore(backup.filePath),
                onDelete: () =>
                  onDelete(backup.filePath),
              )),
          ],
        ),
      ),
    );
  }
}

class _BackupTile extends StatelessWidget {
  const _BackupTile({
    required this.backup,
    required this.onRestore,
    required this.onDelete,
  });

  final BackupInfo backup;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVar,
        borderRadius: BorderRadius.circular(
          AppSizes.radiusSm,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppSizes.radiusSm,
              ),
            ),
            child: const Icon(
              Icons.file_present,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.sm),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                Text(
                  backup.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${backup.fileSizeFormatted} • '
                  '${DateFormat('dd/MM/yyyy HH:mm').format(backup.createdAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Restore button
          IconButton(
            icon: const Icon(
              Icons.restore,
              color: AppColors.info,
            ),
            tooltip: 'Restore',
            onPressed: onRestore,
            iconSize: 20,
          ),

          // Delete button
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
            ),
            tooltip: 'Hapus',
            onPressed: onDelete,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// TIPS CARD
// ═══════════════════════════════════════════════════
class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: AppColors.info,
              ),
              SizedBox(width: AppSizes.sm),
              Text(
                'Tips Backup',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ...[
            '1. Lakukan backup secara rutin (minimal 1x sehari)',
            '2. Simpan file backup ke Google Drive atau USB',
            '3. Backup sebelum update atau ganti device',
            '4. Restore akan mengganti SEMUA data saat ini',
            '5. Setelah restore, restart aplikasi',
            '6. File backup tersimpan di folder CoffeePOS_Backup',
          ].map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// SHARED
// ═══════════════════════════════════════════════════
class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

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
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}