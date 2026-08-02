import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:coffee_pos/core/constant/app_strings.dart';
import 'package:coffee_pos/features/settings/presentation/screens/backup_screen.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../security/presentation/screens/security_settings_screen.dart';
import '../providers/settings_provider.dart';
import 'cloud_sync_screen.dart';
import 'printer_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() =>
    _SettingsScreenState();
}

class _SettingsScreenState
    extends ConsumerState<SettingsScreen> {

  final _nameCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _footerCtrl  = TextEditingController();
  final _taxCtrl     = TextEditingController();
  final _serviceCtrl = TextEditingController();

  bool _initialized = false;
  bool _isSaving    = false;
  bool _hasChanges  = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _footerCtrl.dispose();
    _taxCtrl.dispose();
    _serviceCtrl.dispose();
    super.dispose();
  }

  void _populateForm(SettingsTableData settings) {
    if (_initialized) return;
    _initialized = true;

    _nameCtrl.text    = settings.storeName;
    _addressCtrl.text = settings.storeAddress ?? '';
    _phoneCtrl.text   = settings.storePhone ?? '';
    _footerCtrl.text  = settings.storeFooter ?? '';
    _taxCtrl.text     = settings.taxPercent.toStringAsFixed(0);
    _serviceCtrl.text = settings.servicePercent.toStringAsFixed(0);
  }

  Future<void> _onSave() async {
    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().toIso8601String();
      await ref.read(settingsDatasourceProvider).updateSettings(
        SettingsTableCompanion(
          storeName: Value(_nameCtrl.text.trim()),
          storeAddress: Value(
            _addressCtrl.text.trim().isEmpty
              ? null
              : _addressCtrl.text.trim(),
          ),
          storePhone: Value(
            _phoneCtrl.text.trim().isEmpty
              ? null
              : _phoneCtrl.text.trim(),
          ),
          storeFooter: Value(_footerCtrl.text.trim()),
          taxPercent: Value(
            double.tryParse(_taxCtrl.text) ?? 0,
          ),
          servicePercent: Value(
            double.tryParse(_serviceCtrl.text) ?? 0,
          ),
          updatedAt: Value(now),
        ),
      );

      setState(() => _hasChanges = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Pengaturan berhasil disimpan'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_hasChanges)
            TextButton.icon(
              onPressed: _isSaving ? null : _onSave,
              icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 20,
                  ),
              label: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) {
          if (settings != null) _populateForm(settings);

          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // ═════════════════════════════════
              // PROFIL TOKO
              // ═════════════════════════════════
              _SettingsGroup(
                icon: Icons.store,
                title: 'Profil Toko',
                subtitle: 'Informasi toko untuk struk',
                children: [
                  _InputTile(
                    icon: Icons.badge_outlined,
                    label: 'Nama Toko',
                    controller: _nameCtrl,
                    hint: 'Coffee Shop',
                    onChanged: (_) => _markChanged(),
                  ),
                  _InputTile(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat',
                    controller: _addressCtrl,
                    hint: 'Jl. Contoh No. 1',
                    onChanged: (_) => _markChanged(),
                    maxLines: 2,
                  ),
                  _InputTile(
                    icon: Icons.phone_outlined,
                    label: 'Telepon',
                    controller: _phoneCtrl,
                    hint: '0812-xxxx-xxxx',
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => _markChanged(),
                  ),
                  _InputTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'Footer Struk',
                    controller: _footerCtrl,
                    hint: 'Terima kasih!',
                    onChanged: (_) => _markChanged(),
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.md),

              // ═════════════════════════════════
              // KEUANGAN
              // ═════════════════════════════════
              _SettingsGroup(
                icon: Icons.calculate_outlined,
                title: 'Keuangan',
                subtitle: 'Pajak & service charge',
                children: [
                  _InputTile(
                    icon: Icons.percent,
                    label: 'Pajak / PPN',
                    controller: _taxCtrl,
                    hint: '10',
                    suffix: '%',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (_) => _markChanged(),
                  ),
                  _InputTile(
                    icon: Icons.room_service_outlined,
                    label: 'Service Charge',
                    controller: _serviceCtrl,
                    hint: '5',
                    suffix: '%',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (_) => _markChanged(),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.md),

              // ═════════════════════════════════
              // PERANGKAT
              // ═════════════════════════════════
              _SettingsGroup(
                icon: Icons.devices,
                title: 'Perangkat',
                subtitle: 'Printer & perangkat lain',
                children: [
                  _NavigationTile(
                    icon: Icons.print,
                    iconColor: AppColors.primary,
                    label: 'Printer Bluetooth',
                    subtitle: 'Hubungkan & test printer',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                          const PrinterSettingsScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.md),

              // ═════════════════════════════════
              // DATA & KEAMANAN
              // ═════════════════════════════════
              _SettingsGroup(
                icon: Icons.shield_outlined,
                title: 'Data & Keamanan',
                subtitle: 'Backup, sync & proteksi',
                children: [
                  _NavigationTile(
                    icon: Icons.backup,
                    iconColor: AppColors.success,
                    label: 'Backup & Restore',
                    subtitle: 'Cadangkan data lokal',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                          const BackupRestoreScreen(),
                      ),
                    ),
                  ),
                  _NavigationTile(
                    icon: Icons.cloud_sync,
                    iconColor: AppColors.info,
                    label: 'Cloud Sync',
                    subtitle: 'Auto backup Google Drive',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                          const CloudSyncScreen(),
                      ),
                    ),
                  ),
                  _NavigationTile(
                    icon: Icons.security,
                    iconColor: AppColors.warning,
                    label: 'Keamanan',
                    subtitle: 'PIN, auto lock, password',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                          const SecuritySettingsScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.md),

              // ═════════════════════════════════
              // TENTANG
              // ═════════════════════════════════
              _SettingsGroup(
                icon: Icons.info_outline,
                title: 'Tentang',
                subtitle: 'Info aplikasi',
                children: [
                  _InfoTile(
                    icon: Icons.apps,
                    label: 'Versi Aplikasi',
                    value: AppStrings.appVersion,
                  ),
                  _InfoTile(
                    icon: Icons.wifi_off,
                    label: 'Mode',
                    value: 'Offline',
                  ),
                  _InfoTile(
                    icon: Icons.android,
                    label: 'Platform',
                    value: 'Android',
                  ),
                ],
              ),

              // Save button (mobile)
              if (_hasChanges) ...[
                const SizedBox(height: AppSizes.lg),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _onSave,
                    icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                    label: const Text('Simpan Pengaturan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSizes.xxl),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// SETTINGS GROUP
// ═══════════════════════════════════════════════════
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusSm,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Children
          ...children,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// INPUT TILE
// ═══════════════════════════════════════════════════
class _InputTile extends StatelessWidget {
  const _InputTile({
    required this.icon,
    required this.label,
    required this.controller,
    this.hint,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: maxLines > 1 ? 12 : 0,
            ),
            child: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                suffixText: suffix,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSizes.sm,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// NAVIGATION TILE
// ═══════════════════════════════════════════════════
class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
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
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppSizes.radiusSm,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                    CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// INFO TILE
// ═══════════════════════════════════════════════════
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textHint,
            size: 20,
          ),
          const SizedBox(width: AppSizes.md),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
