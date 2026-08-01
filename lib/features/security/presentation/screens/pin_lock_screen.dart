import 'dart:async';
import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/security_service.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({
    super.key,
    required this.onUnlock,
  });

  final VoidCallback onUnlock;

  @override
  State<PinLockScreen> createState() =>
    _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _enteredPin = '';
  bool   _isError    = false;
  bool   _isLocked   = false;
  String _errorMsg   = '';
  int    _remaining  = 5;
  Timer? _lockTimer;

  final _security = SecurityService.instance;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLockStatus() async {
    final locked = await _security.isLocked();
    final remaining = await _security.getRemainingAttempts();

    setState(() {
      _isLocked = locked;
      _remaining = remaining;
    });

    if (locked) {
      _startLockTimer();
    }
  }

  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        final lockTime =
          await _security.getRemainingLockTime();

        if (lockTime == null || lockTime.isNegative) {
          _lockTimer?.cancel();
          setState(() {
            _isLocked = false;
            _remaining = SecurityService.maxFailedAttempts;
            _errorMsg = '';
          });
        } else {
          setState(() {
            _errorMsg =
              'Terlalu banyak percobaan.\n'
              'Coba lagi dalam '
              '${lockTime.inMinutes}:'
              '${(lockTime.inSeconds % 60)
                .toString()
                .padLeft(2, '0')}';
          });
        }
      },
    );
  }

  void _onKeyTap(String key) {
    if (_isLocked) return;

    HapticFeedback.lightImpact();

    if (key == 'delete') {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin = _enteredPin.substring(
            0, _enteredPin.length - 1,
          );
          _isError = false;
        });
      }
      return;
    }

    if (_enteredPin.length >= 6) return;

    setState(() {
      _enteredPin += key;
      _isError = false;
    });

    // Auto verify saat 4-6 digit
    if (_enteredPin.length >= 4) {
      _verifyPin();
    }
  }

  Future<void> _verifyPin() async {
    final valid = await _security.verifyPin(_enteredPin);

    if (valid) {
      await _security.updateLastActivity();
      widget.onUnlock();
    } else {
      final locked = await _security.isLocked();
      final remaining =
        await _security.getRemainingAttempts();

      setState(() {
        _isError = true;
        _enteredPin = '';
        _remaining = remaining;
        _isLocked = locked;
      });

      if (locked) {
        _startLockTimer();
        setState(() {
          _errorMsg =
            'Terlalu banyak percobaan.\n'
            'Tunggu ${SecurityService.lockDurationMinutes} '
            'menit.';
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
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Lock icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isLocked
                    ? Icons.lock
                    : Icons.lock_open,
                  color: Colors.white,
                  size: 36,
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

              // Error message
              SizedBox(
                height: 40,
                child: _errorMsg.isNotEmpty
                  ? Text(
                      _errorMsg,
                      style: TextStyle(
                        color: _isLocked
                          ? AppColors.warning
                          : AppColors.error,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      'Masukkan PIN 4-6 digit',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
              ),

              const SizedBox(height: AppSizes.lg),

              // PIN dots
              _PinDots(
                length: _enteredPin.length,
                isError: _isError,
              ),

              const Spacer(flex: 1),

              // Numpad
              _NumPad(
                onKeyTap: _onKeyTap,
                isLocked: _isLocked,
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PIN DOTS ──────────────────────────────────────
class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.length,
    required this.isError,
  });

  final int length;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final filled = i < length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          width: filled ? 18 : 14,
          height: filled ? 18 : 14,
          decoration: BoxDecoration(
            color: filled
              ? (isError ? AppColors.error : Colors.white)
              : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isError
                ? AppColors.error
                : Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

// ── NUM PAD ───────────────────────────────────────
class _NumPad extends StatelessWidget {
  const _NumPad({
    required this.onKeyTap,
    required this.isLocked,
  });

  final void Function(String) onKeyTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'delete'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.xl,
      ),
      child: Column(
        children: keys.map((row) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 72, height: 72);
            }
            return _NumKey(
              label: key,
              onTap: () => onKeyTap(key),
              isLocked: isLocked,
            );
          }).toList(),
        )).toList(),
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({
    required this.label,
    required this.onTap,
    required this.isLocked,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(36),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(
                isLocked ? 0.05 : 0.1,
              ),
            ),
            alignment: Alignment.center,
            child: label == 'delete'
              ? Icon(
                  Icons.backspace_outlined,
                  color: Colors.white.withOpacity(
                    isLocked ? 0.3 : 0.8,
                  ),
                  size: 24,
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(
                      isLocked ? 0.3 : 1.0,
                    ),
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}