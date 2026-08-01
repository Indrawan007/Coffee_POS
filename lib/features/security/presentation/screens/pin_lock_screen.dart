import 'dart:async';
import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/hash_helper.dart';
import '../../../../core/utils/security_service.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({
    super.key,
    required this.onUnlock,
  });

  final VoidCallback onUnlock;

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _enteredPin = '';
  bool _isError = false;
  bool _isLocked = false;
  String _errorMsg = '';
  int _savedPinLength = 4;
  int _logoTapCount = 0;
  Timer? _lockTimer;
  Timer? _tapResetTimer;

  final _security = SecurityService.instance;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
    _loadPinLength();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    _tapResetTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPinLength() async {
    final pin = await _security.getPin();
    if (pin != null && mounted) {
      setState(() => _savedPinLength = pin.length);
    }
  }

  Future<void> _checkLockStatus() async {
    final locked = await _security.isLocked();
    setState(() => _isLocked = locked);
    if (locked) _startLockTimer();
  }

  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        final lockTime = await _security.getRemainingLockTime();
        if (lockTime == null || lockTime.isNegative) {
          _lockTimer?.cancel();
          setState(() {
            _isLocked = false;
            _errorMsg = '';
          });
        } else {
          setState(() {
            _errorMsg = 'Terlalu banyak percobaan.\n'
                'Coba lagi dalam '
                '${lockTime.inMinutes}:'
                '${(lockTime.inSeconds % 60).toString().padLeft(2, '0')}';
          });
        }
      },
    );
  }

  void _onLogoTap() {
    _logoTapCount++;
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(
      const Duration(seconds: 3),
      () => _logoTapCount = 0,
    );

    if (_logoTapCount >= 4 && _logoTapCount < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tap ${7 - _logoTapCount}x lagi untuk reset'),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (_logoTapCount >= 7) {
      _logoTapCount = 0;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _EmergencyResetDialog(
          onSuccess: () {
            Navigator.pop(ctx);
            widget.onUnlock();
          },
        ),
      );
    }
  }

  void _onKeyTap(String key) {
    if (_isLocked) return;
    HapticFeedback.lightImpact();

    if (key == 'delete') {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
          _isError = false;
          _errorMsg = '';
        });
      }
      return;
    }

    if (_enteredPin.length >= 6) return;

    setState(() {
      _enteredPin += key;
      _isError = false;
      _errorMsg = '';
    });

    if (_enteredPin.length == _savedPinLength) {
      _verifyPin();
    }
  }

  Future<void> _onSubmit() async {
    if (_enteredPin.length < 4) {
      setState(() {
        _isError = true;
        _errorMsg = 'PIN minimal 4 digit';
      });
      HapticFeedback.heavyImpact();
      return;
    }
    await _verifyPin();
  }

  Future<void> _verifyPin() async {
    final valid = await _security.verifyPin(_enteredPin);

    if (valid) {
      HapticFeedback.mediumImpact();
      await _security.updateLastActivity();
      widget.onUnlock();
    } else {
      final locked = await _security.isLocked();
      final remaining = await _security.getRemainingAttempts();

      setState(() {
        _isError = true;
        _enteredPin = '';
        _isLocked = locked;
      });

      if (locked) {
        _startLockTimer();
        setState(() {
          _errorMsg = 'Terlalu banyak percobaan.\n'
              'Tunggu ${SecurityService.lockDurationMinutes} menit.';
        });
      } else {
        setState(() {
          _errorMsg = 'PIN salah. Sisa $remaining percobaan.';
        });
      }
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              GestureDetector(
                onTap: _onLogoTap,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isLocked ? Icons.lock : Icons.lock_open,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              const Text(
                'Masukkan PIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              SizedBox(
                height: 40,
                child: _errorMsg.isNotEmpty
                    ? Text(
                        _errorMsg,
                        style: TextStyle(
                          color: _isLocked ? AppColors.warning : Colors.redAccent,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        _enteredPin.isEmpty
                            ? 'Masukkan PIN Anda'
                            : '${_enteredPin.length} digit dimasukkan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
              ),

              const SizedBox(height: AppSizes.lg),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_savedPinLength, (i) {
                  final filled = i < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: filled ? 18 : 14,
                    height: filled ? 18 : 14,
                    decoration: BoxDecoration(
                      color: filled
                          ? (_isError ? AppColors.error : Colors.white)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isError
                            ? AppColors.error
                            : Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(flex: 1),

              // Numpad
              _buildNumPad(),

              const Spacer(flex: 1),

              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.lg),
                child: Text(
                  'Lupa PIN? Tap ikon kunci 7x',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumPad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['delete', '0', 'ok'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        children: keys
            .map((row) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row.map((key) {
                    if (key == 'ok') return _buildOkButton();
                    return _buildNumKey(key);
                  }).toList(),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNumKey(String label) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLocked ? null : () => _onKeyTap(label),
          borderRadius: BorderRadius.circular(36),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(_isLocked ? 0.05 : 0.1),
            ),
            alignment: Alignment.center,
            child: label == 'delete'
                ? Icon(
                    Icons.backspace_outlined,
                    color: Colors.white.withOpacity(_isLocked ? 0.3 : 0.8),
                    size: 24,
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(_isLocked ? 0.3 : 1.0),
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOkButton() {
    final enabled = !_isLocked && _enteredPin.length >= 4;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? _onSubmit : null,
          borderRadius: BorderRadius.circular(36),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled
                  ? AppColors.success.withOpacity(0.8)
                  : Colors.white.withOpacity(0.05),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check,
              color: enabled ? Colors.white : Colors.white.withOpacity(0.2),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// EMERGENCY RESET DIALOG
// ═══════════════════════════════════════════════════
class _EmergencyResetDialog extends StatefulWidget {
  const _EmergencyResetDialog({required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  State<_EmergencyResetDialog> createState() =>
      _EmergencyResetDialogState();
}

class _EmergencyResetDialogState extends State<_EmergencyResetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = AppDatabase.instance;
      final hash = HashHelper.hashPassword(_passwordCtrl.text.trim());

      final user = await (db.select(db.usersTable)
            ..where((u) => u.username.equals(_usernameCtrl.text.trim()))
            ..where((u) => u.password.equals(hash))
            ..where((u) => u.role.equals('admin'))
            ..where((u) => u.isActive.equals(true)))
          .getSingleOrNull();

      if (user != null) {
        await SecurityService.instance.removePin();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN berhasil direset ✅'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        widget.onSuccess();
      } else {
        setState(() {
          _error = 'Username atau password admin salah';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal verifikasi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset,
                        color: AppColors.warning, size: 32),
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text('Reset PIN Darurat',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.xs),
                  const Text(
                    'Verifikasi akun Admin untuk\nmereset PIN aplikasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 12)),
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],

                  TextFormField(
                    controller: _usernameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Username Admin',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onVerify(),
                    decoration: InputDecoration(
                      labelText: 'Password Admin',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _onVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              foregroundColor: Colors.white,
                            ),
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Icon(Icons.lock_reset, size: 18),
                            label: Text(
                                _isLoading ? 'Verifikasi...' : 'Reset PIN'),
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