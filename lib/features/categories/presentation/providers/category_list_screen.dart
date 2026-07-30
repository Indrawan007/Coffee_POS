import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/category_provider.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/categories/add'),
          ),
        ],
      ),
      body: stream.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyState(
              message: 'Belum ada kategori',
              icon: Icons.category_outlined,
              action: () => context.go('/categories/add'),
              actionLabel: 'Tambah Kategori',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: categories.length,
            separatorBuilder: (_, __) =>
              const SizedBox(height: AppSizes.sm),
            itemBuilder: (ctx, i) =>
              _CategoryCard(category: categories[i]),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({required this.category});
  final CategoriesTableData category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(categoryFormNotifierProvider.notifier);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: category.isActive
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.border,
          child: Icon(
            Icons.category_outlined,
            color: category.isActive
              ? AppColors.primary
              : AppColors.textHint,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: category.isActive
              ? AppColors.textPrimary
              : AppColors.textHint,
            decoration: category.isActive
              ? null
              : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          category.isActive ? 'Aktif' : 'Nonaktif',
          style: TextStyle(
            fontSize: 12,
            color: category.isActive
              ? AppColors.success
              : AppColors.textHint,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle
            Switch(
              value: category.isActive,
              activeColor: AppColors.primary,
              onChanged: (val) => notifier.toggleActive(
                category.id, val,
              ),
            ),
            // Edit
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              onPressed: () => context.go(
                '/categories/edit/${category.id}',
              ),
            ),
            // Delete
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
              onPressed: () async {
                final confirm = await AppDialog.confirm(
                  context,
                  title: 'Hapus Kategori',
                  message:
                    'Hapus kategori "${category.name}"? '
                    'Pastikan tidak ada produk di kategori ini.',
                  confirmLabel: 'Hapus',
                  confirmColor: AppColors.error,
                );
                if (confirm != true) return;

                final success = await notifier.delete(category.id);

                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Kategori memiliki produk, '
                        'tidak bisa dihapus',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}