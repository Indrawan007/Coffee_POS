import 'package:coffee_pos/features/categories/presentation/providers/category_form_screen.dart';
import 'package:coffee_pos/features/categories/presentation/providers/category_list_screen.dart';
import 'package:coffee_pos/features/settings/presentation/providers/printer_settings_screen.dart';
import 'package:coffee_pos/features/settings/presentation/providers/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/reports/presentation/screens/report_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: _AuthNotifierListenable(ref),
    redirect: (context, state) {
      final isLoggedIn  = authNotifier.user != null;
      final isLoginPage =
        state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isLoginPage) return AppRoutes.login;
      if (isLoggedIn && isLoginPage)  return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.pos,
        builder: (_, __) => const PosScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (_, __) => const ReportScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'printer',
            builder: (_, __) => const PrinterSettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (_, __) => const ProductListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (_, __) => const ProductFormScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (_, state) => ProductFormScreen(
              productId: int.parse(
                state.pathParameters['id']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (_, __) => const CategoryListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (_, __) => const CategoryFormScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (_, state) => CategoryFormScreen(
              categoryId: int.parse(
                state.pathParameters['id']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.users,
        builder: (_, __) => const Scaffold(
          body: Center(
            child: Text('User Management – Coming Soon'),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route error: ${state.error}'),
      ),
    ),
  );
});

class AppRoutes {
  AppRoutes._();
  static const String login      = '/login';
  static const String dashboard  = '/dashboard';
  static const String products   = '/products';
  static const String categories = '/categories';
  static const String pos        = '/pos';
  static const String reports    = '/reports';
  static const String settings   = '/settings';
  static const String users      = '/users';
}

class _AuthNotifierListenable extends ChangeNotifier {
  _AuthNotifierListenable(this._ref) {
    _ref.listen(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
  final Ref _ref;
}