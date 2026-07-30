import 'package:coffee_pos/features/categories/presentation/providers/category_form_screen.dart';
import 'package:coffee_pos/features/categories/presentation/providers/category_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ✅ Import auth provider dengan path yang benar
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';

// ✅ Hapus @riverpod annotation pada router
// ✅ Gunakan Provider biasa dari Riverpod
final appRouterProvider = Provider<GoRouter>((ref) {
  // ✅ Listen ke auth state untuk redirect
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
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        builder: (_, __) => const ProductListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'product-add',
            builder: (_, __) => const ProductFormScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'product-edit',
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
        name: 'categories',
        builder: (_, __) => const CategoryListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'category-add',
            builder: (_, __) => const CategoryFormScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'category-edit',
            builder: (_, state) => CategoryFormScreen(
              categoryId: int.parse(
                state.pathParameters['id']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.pos,
        name: 'pos',
        builder: (_, __) => const PosScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Laporan – Coming Sprint 2')),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Settings – Coming Sprint 2')),
        ),
      ),
      GoRoute(
        path: AppRoutes.users,
        name: 'users',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Users – Coming Sprint 2')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Route tidak ditemukan'),
            Text(
              state.error.toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
});

// ─── ROUTES ───────────────────────────────────────
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

// ─── AUTH LISTENABLE ──────────────────────────────
// ✅ Agar GoRouter bisa refresh saat auth state berubah
class _AuthNotifierListenable extends ChangeNotifier {
  _AuthNotifierListenable(this._ref) {
    _ref.listen(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
}