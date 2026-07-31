import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/datasources/product_datasource.dart';
import '../providers/product_provider.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(productsWithDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pop('/products/add'),
          ),
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          if (products.isEmpty) {
            return EmptyState(
              message: 'Belum ada produk',
              icon: Icons.coffee_outlined,
              action: () => context.push('/products/add'),
              actionLabel: 'Tambah Produk',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: products.length,
            separatorBuilder: (_, __) =>
              const SizedBox(height: AppSizes.sm),
            itemBuilder: (ctx, i) =>
              _ProductCard(item: products[i]),
          );
        },
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.item});
  final ProductWithDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productFormNotifierProvider.notifier);
    final product  = item.product;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          child: product.imagePath != null
            ? Image.asset(
                product.imagePath!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : Container(
                width: 50,
                height: 50,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.coffee,
                  color: AppColors.primary,
                ),
              ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.category.name,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              CurrencyFormatter.format(product.basePrice),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (item.variants.isNotEmpty)
              Text(
                'Varian: ${item.variants.map((v) => v.name).join(', ')}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: product.isActive,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => notifier.toggleActive(
                product.id, val,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              onPressed: () => context.push(
                '/products/edit/${product.id}',
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
              onPressed: () async {
                final confirm = await AppDialog.confirm(
                  context,
                  title: 'Hapus Produk',
                  message: 'Hapus produk "${product.name}"?',
                  confirmLabel: 'Hapus',
                  confirmColor: AppColors.error,
                );
                if (confirm == true) {
                  await notifier.delete(product.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}