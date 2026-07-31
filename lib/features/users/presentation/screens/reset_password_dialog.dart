import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/user_provider.dart';

class ResetPasswordDialog extends ConsumerStatefulWidget {
  const ResetPasswordDialog({
    super.key,
    required this.user,
  });
  final UsersTableData user;

  @override
  ConsumerState<ResetPasswordDialog> createState() =>
    _ResetPasswordDialogState();
}

class _ResetPasswordDialogState
    extends ConsumerState<ResetPasswordDialog> {

  final _formKey      = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _isLoading     = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(userDatasourceProvider).resetPassword(
        id: widget.user.id,
        newPassword: _passwordCtrl.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password ${widget.user.name} '
              'berhasil direset',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
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
      // ✅ Inset padding agar tidak mentok tepi
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppSizes.radiusLg,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        // ✅ Scrollable
        child: SingleChildScrollView(
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
                      const Icon(
                        Icons.lock_reset,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      const Expanded(
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                          Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.sm),

                  // User info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      AppSizes.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary
                        .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusSm,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                            AppColors.primary,
                          child: Text(
                            widget.user.name.isNotEmpty
                              ? widget.user.name[0]
                                  .toUpperCase()
                              : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: AppSizes.sm,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                              CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.name,
                                style: const TextStyle(
                                  fontWeight:
                                    FontWeight.bold,
                                ),
                              ),
                              Text(
                                '@${widget.user.username}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors
                                    .textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Password baru
                  AppTextField(
                    label: 'Password Baru',
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

                  // Konfirmasi
                  AppTextField(
                    label: 'Konfirmasi Password',
                    hint: 'Ulangi password baru',
                    controller: _confirmCtrl,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) {
                      if (v != _passwordCtrl.text) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // Buttons
                  Row(
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
                            style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                  AppColors.accent,
                              ),
                            child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color:
                                        Colors.white,
                                    ),
                                )
                              : const Text(
                                  'Reset Password',
                                ),
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
      ),
    );
  }
}