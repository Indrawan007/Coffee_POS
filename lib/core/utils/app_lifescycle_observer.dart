import 'package:flutter/material.dart';
import 'security_service.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  AppLifecycleObserver({required this.onLock});

  final VoidCallback onLock;
  DateTime? _pausedAt;
  final _security = SecurityService.instance;

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) async {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    }

    if (state == AppLifecycleState.resumed) {
      if (_pausedAt == null) return;

      final pinEnabled = await _security.isPinEnabled();
      final autoLock   = await _security.isAutoLockEnabled();

      if (!pinEnabled || !autoLock) return;

      final delay = await _security.getAutoLockDelay();
      final diff  = DateTime.now().difference(_pausedAt!);

      if (diff.inMinutes >= delay) {
        onLock();
      }

      _pausedAt = null;
    }
  }
}