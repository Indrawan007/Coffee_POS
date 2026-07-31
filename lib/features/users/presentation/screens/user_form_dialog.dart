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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;
    final isSmall      = screenHeight < 700;
    final keyboardOpen =
      MediaQuery.of(context).viewInsets.bottom > 0;

    // ✅ Gunakan full screen bottom sheet di HP kecil
    // Dialog biasa di tablet/layar besar
    if (isSmall || screenWidth < 500) {
      return _buildFullScreen(context);
    }
    return _buildDialog(context);
  }

  // ═══════════════════════════════════════════════
  // FULL SCREEN (HP Kecil)
  // ═══════════════════════════════════════════════
  Widget _buildFullScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Pengguna' : 'Tambah Pengguna',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Save button di appbar
          TextButton(
            onPressed: _isLoading ? null : _onSave,
            child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isEdit ? 'Perbarui' : 'Simpan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: _buildFormContent(),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // DIALOG (Tablet / Layar Besar)
  // ═══════════════════════════════════════════════
  Widget _buildDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppSizes.radiusLg,
        ),
      ),
      // ✅ Batasi ukuran dialog
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
          maxHeight: 620,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.sm,
                0,
              ),
              child: Row(
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
            ),

            const Divider(),

            // ✅ Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg,
                ),
                child: _buildFormContent(),
              ),
            ),

            const Divider(),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () =>
                          Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: SizedBox(
                      height: 48,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // FORM CONTENT (Shared)
  // ═══════════════════════════════════════════════
  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSizes.sm),

          // ── Info box ────────────────────────
          if (!isEdit)
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              margin: const EdgeInsets.only(
                bottom: AppSizes.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppSizes.radiusSm,
                ),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 18,
                  ),
                  SizedBox(width: AppSizes.xs),
                  Expanded(
                    child: Text(
                      'Buat akun baru untuk kasir '
                      'atau admin tambahan.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Role ────────────────────────────
          const Text(
            'Pilih Role',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _RoleCard(
                  label: 'Admin',
                  description: 'Akses semua fitur',
                  icon: Icons.admin_panel_settings,
                  isSelected: _role == 'admin',
                  onTap: () => setState(
                    () => _role = 'admin',
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _RoleCard(
                  label: 'Kasir',
                  description: 'Akses kasir saja',
                  icon: Icons.point_of_sale,
                  isSelected: _role == 'cashier',
                  onTap: () => setState(
                    () => _role = 'cashier',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.md),

          // ── Nama ────────────────────────────
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

          // ── Username ────────────────────────
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

          // ── Password ────────────────────────
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
          ],

          if (isEdit)
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppSizes.radiusSm,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  SizedBox(width: AppSizes.xs),
                  Expanded(
                    child: Text(
                      'Password tidak bisa diubah dari sini. '
                      'Gunakan menu Reset Password.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ROLE CARD
// ═══════════════════════════════════════════════════
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
            // Icon with circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                  ? Colors.white
                  : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                  ? AppColors.primary
                  : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                  ? AppColors.primary.withOpacity(0.7)
                  : AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}