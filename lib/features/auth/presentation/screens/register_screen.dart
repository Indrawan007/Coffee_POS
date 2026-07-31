import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
    _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen> {

  final _formKey      = GlobalKey<FormState>();
  final _storeCtrl    = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  int _currentStep = 0;

  @override
  void dispose() {
    _storeCtrl.dispose();
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).register(
      storeName: _storeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Navigate ke dashboard jika berhasil register
    ref.listen(authNotifierProvider, (prev, next) {
      if (next.isAuthenticated) {
        context.go(AppRoutes.dashboard);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.radiusXl,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // ── HEADER ──────────────
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                            BorderRadius.circular(
                              AppSizes.radiusLg,
                            ),
                        ),
                        child: const Icon(
                          Icons.coffee,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      const Text(
                        'Selamat Datang! ☕',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        'Setup akun pertama untuk memulai',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // ── ERROR ────────────────
                      if (authState.errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(
                            bottom: AppSizes.md,
                          ),
                          padding: const EdgeInsets.all(
                            AppSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error
                              .withOpacity(0.1),
                            borderRadius:
                              BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                            border: Border.all(
                              color: AppColors.error
                                .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(
                                width: AppSizes.sm,
                              ),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── STEP INDICATOR ───────
                      Row(
                        children: [
                          _StepDot(
                            number: 1,
                            label: 'Toko',
                            isActive: _currentStep == 0,
                            isDone: _currentStep > 0,
                          ),
                          Expanded(
                            child: Divider(
                              color: _currentStep > 0
                                ? AppColors.primary
                                : AppColors.border,
                              thickness: 2,
                            ),
                          ),
                          _StepDot(
                            number: 2,
                            label: 'Akun',
                            isActive: _currentStep == 1,
                            isDone: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // ── STEP 1: Info Toko ────
                      if (_currentStep == 0) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '🏪 Informasi Toko',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),

                        AppTextField(
                          label: 'Nama Toko',
                          hint: 'Contoh: Kopi Nusantara',
                          controller: _storeCtrl,
                          prefixIcon: Icons.store_outlined,
                          autofocus: true,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Nama toko wajib diisi';
                            }
                            if (v.trim().length < 3) {
                              return 'Nama toko minimal 3 karakter';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppSizes.xl),

                        AppButton(
                          label: 'Lanjut →',
                          onPressed: () {
                            if (_storeCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context)
                                .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Nama toko wajib diisi',
                                  ),
                                ),
                              );
                              return;
                            }
                            setState(() => _currentStep = 1);
                          },
                        ),
                      ],

                      // ── STEP 2: Info Akun ────
                      if (_currentStep == 1) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '👤 Akun Admin',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),

                        AppTextField(
                          label: 'Nama Lengkap',
                          hint: 'Contoh: Budi Santoso',
                          controller: _nameCtrl,
                          prefixIcon: Icons.person_outline,
                          autofocus: true,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Nama wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.md),

                        AppTextField(
                          label: 'Username',
                          hint: 'Contoh: admin',
                          controller: _usernameCtrl,
                          prefixIcon: Icons.alternate_email,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Username wajib diisi';
                            }
                            if (v.trim().length < 3) {
                              return 'Username minimal 3 karakter';
                            }
                            if (v.contains(' ')) {
                              return 'Username tidak boleh ada spasi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.md),

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
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.md),

                        AppTextField(
                          label: 'Konfirmasi Password',
                          hint: 'Ulangi password',
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

                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: '← Kembali',
                                onPressed: () => setState(
                                  () => _currentStep = 0,
                                ),
                                isOutlined: true,
                              ),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: AppButton(
                                label: 'Mulai! 🚀',
                                onPressed: _onRegister,
                                isLoading: authState.isLoading,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppSizes.md),

                      // Info
                      Container(
                        padding: const EdgeInsets.all(
                          AppSizes.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info
                            .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                              size: 16,
                            ),
                            SizedBox(width: AppSizes.xs),
                            Expanded(
                              child: Text(
                                'Akun ini akan menjadi Admin. '
                                'Kasir dapat ditambahkan nanti.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── STEP DOT WIDGET ──────────────────────────────
class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  final int number;
  final String label;
  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDone
              ? AppColors.success
              : isActive
                ? AppColors.primary
                : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                )
              : Text(
                  '$number',
                  style: TextStyle(
                    color: isActive
                      ? Colors.white
                      : AppColors.textHint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive
              ? AppColors.primary
              : AppColors.textHint,
            fontWeight: isActive
              ? FontWeight.bold
              : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}