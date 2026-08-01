import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/app_dialog.dart';
import '../providers/cloud_sync_provider.dart';

class CloudSyncScreen extends ConsumerWidget {
  const CloudSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(cloudSyncProvider);
    final notifier = ref.read(cloudSyncProvider.notifier);

    ref.listen(cloudSyncProvider, (prev, next) {
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
        Future.delayed(
          const Duration(seconds: 2),
          notifier.clearMessage,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ── STATUS ──────────────────────────
          _StatusCard(state: state),
          const SizedBox(height: AppSizes.md),

          // ── GOOGLE ACCOUNT ──────────────────
          _GoogleAccountCard(
            state: state,
            onSignIn: notifier.signIn,
            onSignOut: () async {
              final confirm = await AppDialog.confirm(
                context,
                title: 'Disconnect Google',
                message:
                  'Auto backup akan dinonaktifkan.\n'
                  'Data lokal tetap aman.',
                confirmLabel: 'Disconnect',
                confirmColor: AppColors.error,
              );
              if (confirm == true) notifier.signOut();
            },
          ),
          const SizedBox(height: AppSizes.md),

          // ── SYNC OPTIONS ────────────────────
          if (state.isSignedIn) ...[
            _SyncOptionsCard(
              state: state,
              onToggleAutoSync: notifier.toggleAutoSync,
              onSyncNow: notifier.syncNow,
              onRestore: () async {
                final confirm = await AppDialog.confirm(
                  context,
                  title: '⚠️ Restore dari Cloud',
                  message:
                    'Data lokal akan DIGANTI dengan '
                    'data dari Google Drive.\n\n'
                    'Lanjutkan?',
                  confirmLabel: 'Ya, Restore',
                  confirmColor: AppColors.warning,
                );
                if (confirm != true) return;

                final success =
                  await notifier.restoreFromCloud();

                if (success && context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Berhasil ✅'),
                      content: const Text(
                        'Data berhasil di-restore.\n'
                        'Restart aplikasi untuk '
                        'menerapkan perubahan.',
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                              .popUntil((r) => r.isFirst);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: AppSizes.md),

            // ── CLOUD INFO ─────────────────────
            if (state.cloudBackupInfo != null)
              _CloudInfoCard(
                info: state.cloudBackupInfo!,
              ),

            const SizedBox(height: AppSizes.md),
          ],

          // ── HOW IT WORKS ────────────────────
          const _HowItWorksCard(),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

// ── STATUS CARD ───────────────────────────────────
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});
  final CloudSyncState state;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    final String status;

    if (!state.hasInternet) {
      color  = AppColors.textHint;
      icon   = Icons.cloud_off;
      status = 'Offline';
    } else if (!state.isSignedIn) {
      color  = AppColors.warning;
      icon   = Icons.cloud_outlined;
      status = 'Belum terhubung';
    } else if (state.isSyncing) {
      color  = AppColors.info;
      icon   = Icons.cloud_sync;
      status = 'Sedang sync...';
    } else {
      color  = AppColors.success;
      icon   = Icons.cloud_done;
      status = 'Terhubung';
    }

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
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Terakhir sync: '
                  '${state.lastSyncFormatted}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (state.isSyncing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }
}

// ── GOOGLE ACCOUNT CARD ───────────────────────────
class _GoogleAccountCard extends StatelessWidget {
  const _GoogleAccountCard({
    required this.state,
    required this.onSignIn,
    required this.onSignOut,
  });

  final CloudSyncState state;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;

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
                Icon(Icons.account_circle,
                  color: AppColors.primary),
                SizedBox(width: AppSizes.sm),
                Text('Akun Google',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )),
              ],
            ),
            const Divider(),

            if (state.isSignedIn) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundImage: state.userPhoto != null
                    ? NetworkImage(state.userPhoto!)
                    : null,
                  backgroundColor: AppColors.primary,
                  child: state.userPhoto == null
                    ? Text(
                        (state.userName ?? '?')[0],
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      )
                    : null,
                ),
                title: Text(state.userName ?? '-'),
                subtitle: Text(
                  state.userEmail ?? '-',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: TextButton(
                  onPressed: onSignOut,
                  child: const Text(
                    'Disconnect',
                    style: TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'Hubungkan akun Google untuk '
                'backup otomatis ke Google Drive.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: state.isLoading
                    ? null
                    : onSignIn,
                  icon: state.isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login),
                  label: Text(
                    state.isLoading
                      ? 'Menghubungkan...'
                      : 'Login dengan Google',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
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

// ── SYNC OPTIONS CARD ─────────────────────────────
class _SyncOptionsCard extends StatelessWidget {
  const _SyncOptionsCard({
    required this.state,
    required this.onToggleAutoSync,
    required this.onSyncNow,
    required this.onRestore,
  });

  final CloudSyncState state;
  final void Function(bool) onToggleAutoSync;
  final VoidCallback onSyncNow;
  final VoidCallback onRestore;

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
                Icon(Icons.sync, color: AppColors.primary),
                SizedBox(width: AppSizes.sm),
                Text('Pengaturan Sync',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )),
              ],
            ),
            const Divider(),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto Sync'),
              subtitle: const Text(
                'Sync otomatis saat terhubung internet',
                style: TextStyle(fontSize: 12),
              ),
              value: state.autoSyncEnabled,
              activeColor: AppColors.primary,
              onChanged: onToggleAutoSync,
            ),

            const Divider(),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: state.isSyncing
                        ? null
                        : onSyncNow,
                      icon: state.isSyncing
                        ? const SizedBox(
                            width: 16, height: 16,
                            child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                          )
                        : const Icon(Icons.cloud_upload),
                      label: Text(
                        state.isSyncing
                          ? 'Syncing...'
                          : 'Sync Sekarang',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: state.isLoading
                        ? null
                        : onRestore,
                      icon: const Icon(
                        Icons.cloud_download,
                        color: AppColors.warning,
                      ),
                      label: const Text('Restore'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: const BorderSide(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── CLOUD INFO CARD ───────────────────────────────
class _CloudInfoCard extends StatelessWidget {
  const _CloudInfoCard({required this.info});
  final Map<String, dynamic> info;

  @override
  Widget build(BuildContext context) {
    final size     = info['size'] ?? 0;
    final modified = info['modified'];

    String sizeStr = '$size B';
    if (size is int && size >= 1024) {
      sizeStr = '${(size / 1024).toStringAsFixed(1)} KB';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud, color: AppColors.info),
                SizedBox(width: AppSizes.sm),
                Text('Backup di Cloud',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )),
              ],
            ),
            const Divider(),
            _InfoRow('File', info['name'] ?? '-'),
            _InfoRow('Ukuran', sizeStr),
            if (modified != null)
              _InfoRow(
                'Terakhir update',
                DateFormat('dd/MM/yyyy HH:mm')
                  .format(modified as DateTime),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── HOW IT WORKS CARD ─────────────────────────────
class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.help_outline, color: AppColors.info),
            SizedBox(width: AppSizes.sm),
            Text('Cara Kerja', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.info)),
          ]),
          SizedBox(height: AppSizes.sm),
          _Step('1', 'Login akun Google'),
          _Step('2', 'Aktifkan Auto Sync'),
          _Step('3', 'Data otomatis ter-backup ke Google Drive'),
          _Step('4', 'Ganti device? Login Google yang sama'),
          _Step('5', 'Tap "Restore" untuk ambil data dari cloud'),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.text);
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.info,
            child: Text(number, style: const TextStyle(
              color: Colors.white, fontSize: 10,
              fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}