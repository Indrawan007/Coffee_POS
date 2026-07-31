import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() =>
    _SettingsScreenState();
}

class _SettingsScreenState
    extends ConsumerState<SettingsScreen> {

  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _footerCtrl    = TextEditingController();
  final _taxCtrl       = TextEditingController();
  final _serviceCtrl   = TextEditingController();

  bool _initialized = false;
  bool _isSaving    = false;

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
    _serviceCtrl.text =
      settings.servicePercent.toStringAsFixed(0);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().toIso8601String();
      await ref
        .read(settingsDatasourceProvider)
        .updateSettings(
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan berhasil disimpan'),
            backgroundColor: AppColors.success,
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

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop('/dashboard'),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) {
          if (settings != null) _populateForm(settings);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── TOKO ──────────────────────
                  const _SectionHeader(
                    icon: Icons.store,
                    title: 'Profil Toko',
                  ),
                  const SizedBox(height: AppSizes.sm),

                  AppTextField(
                    label: 'Nama Toko',
                    controller: _nameCtrl,
                    prefixIcon: Icons.store_outlined,
                    validator: (v) => v == null || v.isEmpty
                      ? 'Nama toko wajib diisi'
                      : null,
                  ),
                  const SizedBox(height: AppSizes.sm),

                  AppTextField(
                    label: 'Alamat (opsional)',
                    controller: _addressCtrl,
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSizes.sm),

                  AppTextField(
                    label: 'No. Telepon (opsional)',
                    controller: _phoneCtrl,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSizes.sm),

                  AppTextField(
                    label: 'Footer Struk',
                    controller: _footerCtrl,
                    prefixIcon: Icons.receipt_outlined,
                    maxLines: 2,
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // ── KEUANGAN ──────────────────
                  const _SectionHeader(
                    icon: Icons.percent,
                    title: 'Keuangan',
                  ),
                  const SizedBox(height: AppSizes.sm),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Pajak (%)',
                          controller: _taxCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                              .digitsOnly,
                          ],
                          prefixIcon: Icons.percent,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: AppTextField(
                          label: 'Service Charge (%)',
                          controller: _serviceCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                              .digitsOnly,
                          ],
                          prefixIcon: Icons.percent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // ── PRINTER ───────────────────
                  const _SectionHeader(
                    icon: Icons.print,
                    title: 'Printer',
                  ),
                  const SizedBox(height: AppSizes.sm),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.bluetooth,
                      color: AppColors.primary,
                    ),
                    title: const Text('Pengaturan Printer'),
                    subtitle: const Text(
                      'Hubungkan dan test printer Bluetooth',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () =>
                      context.push('/settings/printer'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMd,
                      ),
                      side: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // ── SAVE BUTTON ───────────────
                  AppButton(
                    label: 'Simpan Pengaturan',
                    onPressed: _onSave,
                    isLoading: _isSaving,
                    icon: Icons.save_outlined,
                  ),

                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSizes.sm),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}