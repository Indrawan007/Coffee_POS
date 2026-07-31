import 'package:coffee_pos/features/categories/presentation/providers/category_form_screen.dart';
import 'package:coffee_pos/features/categories/presentation/providers/category_list_screen.dart';
import 'package:coffee_pos/features/settings/presentation/providers/printer_settings_screen.dart';
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
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/users/presentation/screens/user_management_screen.dart';

// ✅ Halaman loading sementara
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat...'),
          ],
        ),
      ),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState     = ref.watch(authNotifierProvider);
  final hasUsersAsync = ref.watch(hasUsersProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final currentPath = state.matchedLocation;

      // ── STEP 1: Jika masih loading → tetap di splash
      if (hasUsersAsync.isLoading) {
        if (currentPath != AppRoutes.splash) {
          return AppRoutes.splash;
        }
        return null;
      }

      // ── STEP 2: Ambil nilai
      final hasUsers  = hasUsersAsync.value ?? false;
      final isLoggedIn = authState.isAuthenticated;

      // ── STEP 3: Definisi halaman auth
      final isAuthPage =
        currentPath == AppRoutes.login ||
        currentPath == AppRoutes.register ||
        currentPath == AppRoutes.splash;

      // ── STEP 4: Belum ada user → harus register
      if (!hasUsers) {
        if (currentPath != AppRoutes.register) {
          return AppRoutes.register;
        }
        return null; // ✅ Sudah di register, jangan redirect lagi
      }

      // ── STEP 5: Ada user tapi belum login → ke login
      if (hasUsers && !isLoggedIn) {
        if (currentPath != AppRoutes.login) {
          return AppRoutes.login;
        }
        return null; // ✅ Sudah di login, jangan redirect lagi
      }

      // ── STEP 6: Sudah login, masih di halaman auth → dashboard
      if (isLoggedIn && isAuthPage) {
        return AppRoutes.dashboard;
      }

      // ── STEP 7: Semua ok → tidak redirect
      return null;
    },
    routes: [
      // ── SPLASH ──────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const _SplashScreen(),
      ),

      // ── AUTH ────────────────────────────────
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),

      // ── MAIN ────────────────────────────────
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

      // ── SETTINGS ────────────────────────────
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

      // ── PRODUCTS ────────────────────────────
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

      // ── CATEGORIES ──────────────────────────
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

      // ── USERS ───────────────────────────────
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

// ─── ROUTES ───────────────────────────────────────
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

// ─── REFRESH LISTENABLE ───────────────────────────
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