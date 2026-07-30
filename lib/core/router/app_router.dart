import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/categories/presentation/screens/category_list_screen.dart';
import '../../features/categories/presentation/screens/category_form_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoginPage = state.matchedLocation == AppRoutes.login;

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
              productId: int.parse(state.pathParameters['id']!),
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
              categoryId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route tidak ditemukan: ${state.error}'),
      ),
    ),
  );
}

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