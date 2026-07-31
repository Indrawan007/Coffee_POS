import 'package:coffee_pos/core/constant/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/database/app_database.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  await initializeDateFormatting('id_ID', null);

  // ✅ Initialize database SEKALI di awal
  // Ini memastikan DB siap sebelum app render
  final _ = AppDatabase.instance;

  runApp(
    const ProviderScope(
      child: CoffeePosApp(),
    ),
  );
}

class CoffeePosApp extends ConsumerWidget {
  const CoffeePosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Coffee POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}