import 'package:coffee_pos/core/constant/app_theme.dart';
import 'package:coffee_pos/core/utils/app_lifescycle_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/database/app_database.dart';
import 'core/router/app_router.dart';
import 'core/utils/auto_sync_service.dart';
import 'core/utils/security_service.dart';
import 'features/security/presentation/screens/pin_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  await initializeDateFormatting('id_ID', null);

  final _ = AppDatabase.instance;
  AutoSyncService.instance.start();

  runApp(
    const ProviderScope(
      child: CoffeePosApp(),
    ),
  );
}

class CoffeePosApp extends ConsumerStatefulWidget {
  const CoffeePosApp({super.key});

  @override
  ConsumerState<CoffeePosApp> createState() =>
    _CoffeePosAppState();
}

class _CoffeePosAppState
    extends ConsumerState<CoffeePosApp> {

  bool _isLocked = false;
  late AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();

    _lifecycleObserver = AppLifecycleObserver(
      onLock: () => setState(() => _isLocked = true),
    );
    WidgetsBinding.instance.addObserver(
      _lifecycleObserver,
    );

    _checkInitialLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      _lifecycleObserver,
    );
    super.dispose();
  }

  Future<void> _checkInitialLock() async {
    final pinEnabled =
      await SecurityService.instance.isPinEnabled();
    if (pinEnabled) {
      setState(() => _isLocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    // ✅ Tampilkan PIN Lock di atas semua screen
    if (_isLocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: PinLockScreen(
          onUnlock: () => setState(
            () => _isLocked = false,
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Coffee POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}