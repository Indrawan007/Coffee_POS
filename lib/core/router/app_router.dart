import 'package:coffee_pos/features/categories/presentation/providers/category_form_screen.dart';
import 'package:coffee_pos/features/categories/presentation/providers/category_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/reports/presentation/screens/report_screen.dart';
import '../../features/settings/presentation/screens/printer_settings_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/users/presentation/screens/user_management_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState     = ref.watch(authNotifierProvider);
  final hasUsersAsync = ref.watch(hasUsersProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final currentPath = state.matchedLocation;

      // ── STEP 1: Loading → tetap di splash ─────
      if (hasUsersAsync.isLoading) {
        return currentPath == AppRoutes.splash
          ? null
          : AppRoutes.splash;
      }

      // ── STEP 2: Ambil nilai ───────────────────
      final hasUsers   = hasUsersAsync.value ?? false;
      final isLoggedIn = authState.isAuthenticated;

      // ── STEP 3: Belum ada user → register ─────
      if (!hasUsers) {
        return currentPath == AppRoutes.register
          ? null
          : AppRoutes.register;
      }

      // ── STEP 4: Belum login → login ───────────
      if (!isLoggedIn) {
        return currentPath == AppRoutes.login
          ? null
          : AppRoutes.login;
      }

      // ── STEP 5: Sudah login, di auth → dashboard
      if (currentPath == AppRoutes.splash ||
          currentPath == AppRoutes.login ||
          currentPath == AppRoutes.register) {
        return AppRoutes.dashboard;
      }

      // ── STEP 6: Semua ok ──────────────────────
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
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
            builder: (_, __) =>
              const PrinterSettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (_, __) => const ProductListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (_, __) =>
              const ProductFormScreen(),
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
            builder: (_, __) =>
              const CategoryFormScreen(),
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
        builder: (_, __) =>
          const UserManagementScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
});

class AppRoutes {
  AppRoutes._();
  static const String splash     = '/';
  static const String register   = '/register';
  static const String login      = '/login';
  static const String dashboard  = '/dashboard';
  static const String products   = '/products';
  static const String categories = '/categories';
  static const String pos        = '/pos';
  static const String reports    = '/reports';
  static const String settings   = '/settings';
  static const String users      = '/users';
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });
    _ref.listen(hasUsersProvider, (_, __) {
      notifyListeners();
    });
  }
  final Ref _ref;
}