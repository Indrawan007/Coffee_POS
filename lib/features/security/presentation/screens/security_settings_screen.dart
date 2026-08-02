import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/security_service.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../users/presentation/providers/user_provider.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  final _security = SecurityService.instance;

  bool _pinEnabled = false;
  bool _autoLock = true;
  int _autoLockDelay = 1;
  int _sessionTimeout = 60;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final pin = await _security.isPinEnabled();
    final auto = await _security.isAutoLockEnabled();
    final delay = await _security.getAutoLockDelay();
    final timeout = await _security.getSessionTimeout();

    if (mounted) {
      setState(() {
        _pinEnabled = pin;
        _autoLock = auto;
        _autoLockDelay = delay;
        _sessionTimeout = timeout;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keamanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                // ── PIN LOCK ──────────────────
                _SectionCard(
                  icon: Icons.pin,
                  title: 'Kunci PIN',
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Aktifkan PIN'),
                      subtitle: const Text(
                        'Kunci app dengan PIN saat dibuka',
                      ),
                      value: _pinEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (val) async {
                        if (val) {
                          _showSetPinDialog();
                        } else {
                          final confirm = await AppDialog.confirm(
                            context,
                            title: 'Nonaktifkan PIN',
                            message: 'Yakin ingin menonaktifkan '
                                'kunci PIN?',
                            confirmColor: AppColors.error,
                          );
                          if (confirm == true) {
                            await _security.removePin();
                            setState(
                              () => _pinEnabled = false,
                            );
                          }
                        }
                      },
                    ),
                    if (_pinEnabled) ...[
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Ubah PIN'),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: _showChangePinDialog,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSizes.md),

                // ── AUTO LOCK ─────────────────
                if (_pinEnabled)
                  _SectionCard(
                    icon: Icons.timer,
                    title: 'Auto Lock',
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Auto Lock'),
                        subtitle: const Text(
                          'Kunci otomatis saat app '
                          'di-background',
                        ),
                        value: _autoLock,
                        activeColor: AppColors.primary,
                        onChanged: (val) async {
                          await _security.setAutoLock(val);
                          setState(
                            () => _autoLock = val,
                          );
                        },
                      ),
                      if (_autoLock) ...[
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Delay Auto Lock',
                          ),
                          subtitle: Text(
                            '$_autoLockDelay menit',
                          ),
                          trailing: DropdownButton<int>(
                            value: _autoLockDelay,
                            underline: const SizedBox.shrink(),
                            items: [1, 3, 5, 10, 15]
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text('$v menit'),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) async {
                              if (val != null) {
                                await _security.setAutoLockDelay(val);
                                setState(
                                  () => _autoLockDelay = val,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),

                if (_pinEnabled) const SizedBox(height: AppSizes.md),

                // ── SESSION TIMEOUT ───────────
                _SectionCard(
                  icon: Icons.access_time,
                  title: 'Session Timeout',
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Logout Otomatis',
                      ),
                      subtitle: Text(
                        'Setelah $_sessionTimeout menit '
                        'tidak aktif',
                      ),
                      trailing: DropdownButton<int>(
                        value: _sessionTimeout,
                        underline: const SizedBox.shrink(),
                        items: [15, 30, 60, 120, 480]
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(
                                  v < 60 ? '$v menit' : '${v ~/ 60} jam',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) async {
                          if (val != null) {
                            await _security.setSessionTimeout(val);
                            setState(
                              () => _sessionTimeout = val,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),

                // ── CHANGE PASSWORD ───────────
                _SectionCard(
                  icon: Icons.password,
                  title: 'Password',
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ganti Password'),
                      subtitle: const Text(
                        'Ubah password akun Anda',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () => _showChangePasswordDialog(
                        authState.user?.id,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),

                // ── INFO ──────────────────────
                _SecurityInfoCard(),

                const SizedBox(height: AppSizes.xl),
              ],
            ),
    );
  }

  // ── SET PIN DIALOG ────────────────────────────
void _showSetPinDialog() {
    String pin = '';
    String confirmPin = '';
    bool isConfirmStep = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            isConfirmStep ? 'Konfirmasi PIN' : 'Buat PIN Baru',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isConfirmStep
                    ? 'Masukkan PIN sekali lagi'
                    : 'Masukkan 6 digit PIN',
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '● ● ● ● ● ●',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (val) {
                  if (isConfirmStep) {
                    confirmPin = val;
                  } else {
                    pin = val;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!isConfirmStep) {
                  // ✅ Harus 6 digit
                  if (pin.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'PIN harus 6 digit',
                        ),
                      ),
                    );
                    return;
                  }
                  setDialogState(
                    () => isConfirmStep = true,
                  );
                } else {
                  if (confirmPin != pin) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'PIN tidak cocok',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  await _security.setPin(pin);
                  setState(() => _pinEnabled = true);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'PIN berhasil dibuat ✅',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              child: Text(
                isConfirmStep ? 'Simpan' : 'Lanjut',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CHANGE PIN ────────────────────────────────
  void _showChangePinDialog() {
    _showSetPinDialog();
  }

  // ── CHANGE PASSWORD ───────────────────────────
  void _showChangePasswordDialog(int? userId) {
    if (userId == null) return;

    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Password Lama',
                controller: oldCtrl,
                isPassword: true,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: AppSizes.sm),
              AppTextField(
                label: 'Password Baru',
                controller: newCtrl,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Wajib diisi';
                  }
                  if (v.length < 6) {
                    return 'Minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.sm),
              AppTextField(
                label: 'Konfirmasi',
                controller: confirmCtrl,
                isPassword: true,
                validator: (v) => v != newCtrl.text ? 'Tidak cocok' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              // Verify old password
              final ds = ref.read(
                userDatasourceProvider,
              );

              try {
                await ds.resetPassword(
                  id: userId,
                  newPassword: newCtrl.text,
                );

                if (ctx.mounted) Navigator.pop(ctx);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password berhasil diubah ✅',
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
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

// ── SECTION CARD ──────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

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
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ── INFO CARD ─────────────────────────────────────
class _SecurityInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: AppColors.info),
              SizedBox(width: AppSizes.sm),
              Text(
                'Tips Keamanan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            '• Aktifkan PIN untuk mencegah akses tidak sah\n'
            '• Gunakan password yang kuat (min 6 karakter)\n'
            '• Jangan bagikan PIN/password ke orang lain\n'
            '• Aktifkan auto lock saat meninggalkan device\n'
            '• Backup data secara rutin',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
