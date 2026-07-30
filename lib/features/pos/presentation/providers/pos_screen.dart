import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../products/data/datasources/product_datasource.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_panel.dart';
import '../widgets/product_grid.dart';
import '../widgets/category_tab.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  int? _selectedCategoryId;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart          = ref.watch(cartNotifierProvider);
    final categoriesAsync = ref.watch(activeCategoriesStreamProvider);
    final productsAsync = ref.watch(productsWithDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('☕ Kasir'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          // Total item badge
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.sm,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(
                AppSizes.radiusFull,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${cart.totalItems} item',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // ── KIRI: Kategori ────────────────────
          categoriesAsync.when(
            loading: () => const SizedBox(
              width: AppSizes.categoryWidth,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => const SizedBox(width: 80),
            data: (categories) => CategoryTab(
              categories: categories,
              selectedId: _selectedCategoryId,
              onSelect: (id) => setState(
                () => _selectedCategoryId = id,
              ),
            ),
          ),

          // ── TENGAH: Produk ────────────────────
          Expanded(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                    ),
                    onChanged: (val) =>
                      setState(() => _searchQuery = val),
                  ),
                ),

                // Product grid
                Expanded(
                  child: productsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) =>
                      Center(child: Text('Error: $e')),
                    data: (products) {
                      // Filter by category & search
                      var filtered = products.where((p) =>
                        p.product.isActive,
                      ).toList();

                      if (_selectedCategoryId != null) {
                        filtered = filtered.where((p) =>
                          p.product.categoryId ==
                          _selectedCategoryId,
                        ).toList();
                      }

                      if (_searchQuery.isNotEmpty) {
                        filtered = filtered.where((p) =>
                          p.product.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        ).toList();
                      }

                      return ProductGrid(products: filtered);
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── KANAN: Cart ───────────────────────
          const CartPanel(),
        ],
      ),
    );
  }
}