import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/app_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user      = authState.user;
    final isAdmin   = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('☕ Coffee POS'),
        actions: [
          Text(
            'Halo, ${user?.name ?? '-'}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: AppSizes.sm),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await AppDialog.confirm(
                context,
                title: 'Logout',
                message: 'Yakin ingin keluar?',
                confirmLabel: 'Logout',
                confirmColor: AppColors.error,
              );
              if (confirm == true) {
                ref.read(authNotifierProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(
                  AppSizes.radiusLg,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.coffee,
                    color: AppColors.textOnPrimary,
                    size: 40,
                  ),
                  const SizedBox(width: AppSizes.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang!',
                        style: const TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${user?.name} • ${user?.role == 'admin' ? 'Admin' : 'Kasir'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),
            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Menu Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: AppSizes.md,
                mainAxisSpacing: AppSizes.md,
                children: [
                  _MenuCard(
                    icon: Icons.point_of_sale,
                    label: 'Kasir',
                    color: AppColors.accent,
                    onTap: () => context.go(AppRoutes.pos),
                  ),
                  if (isAdmin) ...[
                    _MenuCard(
                      icon: Icons.coffee_outlined,
                      label: 'Produk',
                      color: AppColors.primary,
                      onTap: () => context.go(AppRoutes.products),
                    ),
                    _MenuCard(
                      icon: Icons.category_outlined,
                      label: 'Kategori',
                      color: AppColors.primaryLight,
                      onTap: () => context.go(AppRoutes.categories),
                    ),
                    _MenuCard(
                      icon: Icons.bar_chart,
                      label: 'Laporan',
                      color: AppColors.success,
                      onTap: () => context.go(AppRoutes.reports),
                    ),
                    _MenuCard(
                      icon: Icons.people_outline,
                      label: 'Pengguna',
                      color: AppColors.info,
                      onTap: () => context.go(AppRoutes.users),
                    ),
                    _MenuCard(
                      icon: Icons.settings_outlined,
                      label: 'Pengaturan',
                      color: AppColors.textSecondary,
                      onTap: () => context.go(AppRoutes.settings),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: AppSizes.sm),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}