import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/user_provider.dart';

class UserFormDialog extends ConsumerStatefulWidget {
  const UserFormDialog({super.key, this.user});
  final UsersTableData? user;

  @override
  ConsumerState<UserFormDialog> createState() =>
    _UserFormDialogState();
}

class _UserFormDialogState
    extends ConsumerState<UserFormDialog> {

  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role        = 'cashier';
  bool   _isLoading   = false;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameCtrl.text     = widget.user!.name;
      _usernameCtrl.text = widget.user!.username;
      _role              = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final ds = ref.read(userDatasourceProvider);

      if (isEdit) {
        await ds.update(
          id: widget.user!.id,
          name: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          role: _role,
        );
      } else {
        await ds.insert(
          name: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _role,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                ? 'Pengguna berhasil diperbarui'
                : 'Pengguna berhasil ditambahkan',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppSizes.radiusLg,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      isEdit
                        ? Icons.edit
                        : Icons.person_add,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      isEdit
                        ? 'Edit Pengguna'
                        : 'Tambah Pengguna',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                        Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.md),

                // Nama
                AppTextField(
                  label: 'Nama Lengkap',
                  hint: 'Contoh: Budi Santoso',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),

                // Username
                AppTextField(
                  label: 'Username',
                  hint: 'Contoh: budi',
                  controller: _usernameCtrl,
                  prefixIcon: Icons.alternate_email,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Username wajib diisi';
                    }
                    if (v.trim().length < 3) {
                      return 'Minimal 3 karakter';
                    }
                    if (v.contains(' ')) {
                      return 'Tidak boleh ada spasi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),

                // Password (hanya saat tambah baru)
                if (!isEdit) ...[
                  AppTextField(
                    label: 'Password',
                    hint: 'Minimal 6 karakter',
                    controller: _passwordCtrl,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (v.length < 6) {
                        return 'Minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                ],

                // Role
                const Text(
                  'Role',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    Expanded(
                      child: _RoleChip(
                        label: 'Admin',
                        icon: Icons.admin_panel_settings,
                        isSelected: _role == 'admin',
                        onTap: () => setState(
                          () => _role = 'admin',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: _RoleChip(
                        label: 'Kasir',
                        icon: Icons.point_of_sale,
                        isSelected: _role == 'cashier',
                        onTap: () => setState(
                          () => _role = 'cashier',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xl),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                          Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                          ? null
                          : _onSave,
                        child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                            )
                          : Text(
                              isEdit
                                ? 'Perbarui'
                                : 'Simpan',
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surfaceVar,
          borderRadius: BorderRadius.circular(
            AppSizes.radiusMd,
          ),
          border: Border.all(
            color: isSelected
              ? AppColors.primary
              : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
                fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}