import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  SecurityService._();
  static final SecurityService instance = SecurityService._();

  static const _prefPin           = 'app_pin';
  static const _prefPinEnabled    = 'pin_enabled';
  static const _prefAutoLock      = 'auto_lock_enabled';
  static const _prefAutoLockDelay = 'auto_lock_delay';
  static const _prefSessionTimeout = 'session_timeout';
  static const _prefFailedAttempts = 'failed_attempts';
  static const _prefLockedUntil   = 'locked_until';
  static const _prefLastActivity  = 'last_activity';

  static const maxFailedAttempts = 5;
  static const lockDurationMinutes = 5;

  // ─── PIN ──────────────────────────────────────

  Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefPinEnabled) ?? false;
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefPin, pin);
    await prefs.setBool(_prefPinEnabled, true);
  }

  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefPin);
    await prefs.setBool(_prefPinEnabled, false);
  }

  Future<bool> verifyPin(String pin) async {
    // Cek apakah sedang di-lock
    if (await isLocked()) return false;

    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_prefPin);

    if (savedPin == pin) {
      await _resetFailedAttempts();
      return true;
    }

    await _incrementFailedAttempts();
    return false;
  }

  Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefPin);
  }

  // ─── AUTO LOCK ────────────────────────────────

  Future<bool> isAutoLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefAutoLock) ?? true;
  }

  Future<void> setAutoLock(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAutoLock, enabled);
  }

  Future<int> getAutoLockDelay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefAutoLockDelay) ?? 1;
  }

  Future<void> setAutoLockDelay(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefAutoLockDelay, minutes);
  }

  // ─── SESSION TIMEOUT ──────────────────────────

  Future<int> getSessionTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefSessionTimeout) ?? 60;
  }

  Future<void> setSessionTimeout(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefSessionTimeout, minutes);
  }

  Future<void> updateLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefLastActivity,
      DateTime.now().toIso8601String(),
    );
  }

  Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_prefLastActivity);
    if (lastStr == null) return false;

    final lastActivity = DateTime.tryParse(lastStr);
    if (lastActivity == null) return false;

    final timeout = await getSessionTimeout();
    final diff = DateTime.now().difference(lastActivity);

    return diff.inMinutes >= timeout;
  }

  // ─── LOGIN ATTEMPT LIMIT ──────────────────────

  Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefFailedAttempts) ?? 0;
  }

  Future<void> _incrementFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_prefFailedAttempts) ?? 0;
    final newCount = current + 1;

    await prefs.setInt(_prefFailedAttempts, newCount);

    if (newCount >= maxFailedAttempts) {
      final lockUntil = DateTime.now().add(
        const Duration(minutes: lockDurationMinutes),
      );
      await prefs.setString(
        _prefLockedUntil,
        lockUntil.toIso8601String(),
      );
      debugPrint(
        'Account locked until: $lockUntil',
      );
    }
  }

  Future<void> _resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefFailedAttempts, 0);
    await prefs.remove(_prefLockedUntil);
  }

  Future<bool> isLocked() async {
    final prefs = await SharedPreferences.getInstance();
    final lockedStr = prefs.getString(_prefLockedUntil);

    if (lockedStr == null) return false;

    final lockedUntil = DateTime.tryParse(lockedStr);
    if (lockedUntil == null) return false;

    if (DateTime.now().isAfter(lockedUntil)) {
      await _resetFailedAttempts();
      return false;
    }

    return true;
  }

  Future<Duration?> getRemainingLockTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lockedStr = prefs.getString(_prefLockedUntil);

    if (lockedStr == null) return null;

    final lockedUntil = DateTime.tryParse(lockedStr);
    if (lockedUntil == null) return null;

    final remaining = lockedUntil.difference(DateTime.now());
    if (remaining.isNegative) return null;

    return remaining;
  }

  Future<int> getRemainingAttempts() async {
    final failed = await getFailedAttempts();
    return maxFailedAttempts - failed;
  }
}