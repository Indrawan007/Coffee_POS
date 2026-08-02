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

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() =>
    _ProductListScreenState();
}

class _ProductListScreenState
    extends ConsumerState<ProductListScreen> {

  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, inactive
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(productsWithDetailsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Filter
          PopupMenuButton<String>(
            icon: Badge(
              isLabelVisible: _filterStatus != 'all',
              smallSize: 8,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter',
            onSelected: (val) => setState(
              () => _filterStatus = val,
            ),
            itemBuilder: (_) => [
              _filterItem('all', 'Semua', Icons.list),
              _filterItem(
                'active', 'Tersedia', Icons.check_circle,
              ),
              _filterItem(
                'inactive', 'Habis', Icons.cancel,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── SEARCH BAR ──────────────────────
          _SearchBar(
            controller: _searchCtrl,
            query: _searchQuery,
            onChanged: (val) => setState(
              () => _searchQuery = val,
            ),
            onClear: () {
              _searchCtrl.clear();
              setState(() => _searchQuery = '');
            },
          ),

          // ── STATS BAR ───────────────────────
          asyncData.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (products) => _StatsBar(
              total: products.length,
              active: products
                .where((p) => p.product.isActive)
                .length,
              inactive: products
                .where((p) => !p.product.isActive)
                .length,
              selectedFilter: _filterStatus,
              onFilter: (val) => setState(
                () => _filterStatus = val,
              ),
            ),
          ),

          // ── PRODUCT LIST ────────────────────
          Expanded(
            child: asyncData.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e'),
              ),
              data: (products) {
                var filtered = products.toList();

                // Filter status
                if (_filterStatus == 'active') {
                  filtered = filtered
                    .where((p) => p.product.isActive)
                    .toList();
                } else if (_filterStatus == 'inactive') {
                  filtered = filtered
                    .where((p) => !p.product.isActive)
                    .toList();
                }

                // Filter search
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered
                    .where((p) => p.product.name
                      .toLowerCase()
                      .contains(
                        _searchQuery.toLowerCase(),
                      ))
                    .toList();
                }

                if (filtered.isEmpty) {
                  return EmptyState(
                    message: _searchQuery.isNotEmpty
                      ? 'Produk "$_searchQuery"\ntidak ditemukan'
                      : 'Belum ada produk',
                    icon: Icons.coffee_outlined,
                    action: () =>
                      context.push('/products/add'),
                    actionLabel: 'Tambah Produk',
                  );
                }

                return isWide
                  ? _GridView(products: filtered)
                  : _ListView(products: filtered);
              },
            ),
          ),
        ],
      ),

      // ── FAB ─────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products/add'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  PopupMenuItem<String> _filterItem(
    String value,
    String label,
    IconData icon,
  ) {
    final selected = _filterStatus == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: selected
              ? AppColors.primary
              : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: selected
                ? FontWeight.bold
                : FontWeight.normal,
              color: selected
                ? AppColors.primary
                : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// SEARCH BAR
// ═══════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final void Function(String) onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        AppSizes.xs,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceVar,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppSizes.radiusFull,
            ),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// STATS BAR
// ═══════════════════════════════════════════════════
class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.total,
    required this.active,
    required this.inactive,
    required this.selectedFilter,
    required this.onFilter,
  });

  final int total;
  final int active;
  final int inactive;
  final String selectedFilter;
  final void Function(String) onFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.sm,
      ),
      child: Row(
        children: [
          _StatChip(
            label: 'Semua ($total)',
            isSelected: selectedFilter == 'all',
            onTap: () => onFilter('all'),
          ),
          const SizedBox(width: AppSizes.xs),
          _StatChip(
            label: 'Tersedia ($active)',
            isSelected: selectedFilter == 'active',
            color: AppColors.success,
            onTap: () => onFilter('active'),
          ),
          const SizedBox(width: AppSizes.xs),
          _StatChip(
            label: 'Habis ($inactive)',
            isSelected: selectedFilter == 'inactive',
            color: AppColors.error,
            onTap: () => onFilter('inactive'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
            ? chipColor.withOpacity(0.15)
            : AppColors.surfaceVar,
          borderRadius: BorderRadius.circular(
            AppSizes.radiusFull,
          ),
          border: Border.all(
            color: isSelected
              ? chipColor
              : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected
              ? FontWeight.bold
              : FontWeight.normal,
            color: isSelected
              ? chipColor
              : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// LIST VIEW (HP)
// ═══════════════════════════════════════════════════
class _ListView extends ConsumerWidget {
  const _ListView({required this.products});
  final List<ProductWithDetails> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        100, // space for FAB
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => _ProductListCard(
        item: products[i],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// GRID VIEW (Tablet)
// ═══════════════════════════════════════════════════
class _GridView extends ConsumerWidget {
  const _GridView({required this.products});
  final List<ProductWithDetails> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        100,
      ),
      gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSizes.sm,
          mainAxisSpacing: AppSizes.sm,
          childAspectRatio: 2.8,
        ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => _ProductListCard(
        item: products[i],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// PRODUCT CARD
// ═══════════════════════════════════════════════════
class _ProductListCard extends ConsumerWidget {
  const _ProductListCard({required this.item});
  final ProductWithDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = item.product;
    final notifier = ref.read(
      productFormNotifierProvider.notifier,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
        side: BorderSide(
          color: product.isActive
            ? AppColors.border
            : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
        onTap: () => context.push(
          '/products/edit/${product.id}',
        ),
        child: Opacity(
          opacity: product.isActive ? 1.0 : 0.6,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                // ── IMAGE ─────────────────────
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                      .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusMd,
                    ),
                  ),
                  child: product.imagePath != null
                    ? ClipRRect(
                        borderRadius:
                          BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        child: Image.asset(
                          product.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                            const Icon(
                              Icons.coffee,
                              color: AppColors.primary,
                            ),
                        ),
                      )
                    : const Icon(
                        Icons.coffee,
                        color: AppColors.primary,
                      ),
                ),

                const SizedBox(width: AppSizes.md),

                // ── INFO ──────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                      CrossAxisAlignment.start,
                    children: [
                      // Name + status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight:
                                  FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow:
                                TextOverflow.ellipsis,
                            ),
                          ),
                          // Status dot
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: product.isActive
                                ? AppColors.success
                                : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Category + price
                      Row(
                        children: [
                          // Category badge
                          Container(
                            padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                .withOpacity(0.1),
                              borderRadius:
                                BorderRadius.circular(
                                  AppSizes.radiusFull,
                                ),
                            ),
                            child: Text(
                              item.category.name,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight:
                                  FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: AppSizes.sm,
                          ),

                          // Price
                          Text(
                            CurrencyFormatter.format(
                              product.basePrice,
                            ),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      // Variants
                      if (item.variants.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.variants
                            .map((v) => v.name)
                            .join(' • '),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── ACTIONS ───────────────────
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  onSelected: (val) =>
                    _onAction(context, ref, val),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                            size: 18,
                            color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            product.isActive
                              ? Icons.block
                              : Icons.check_circle,
                            size: 18,
                            color: product.isActive
                              ? AppColors.warning
                              : AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.isActive
                              ? 'Tandai Habis'
                              : 'Tandai Tersedia',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                            size: 18,
                            color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Hapus',
                            style: TextStyle(
                              color: AppColors.error,
                            )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final notifier = ref.read(
      productFormNotifierProvider.notifier,
    );

    switch (action) {
      case 'edit':
        context.push('/products/edit/${item.product.id}');
        break;
      case 'toggle':
        await notifier.toggleActive(
          item.product.id,
          !item.product.isActive,
        );
        break;
      case 'delete':
        final confirm = await AppDialog.confirm(
          context,
          title: 'Hapus Produk',
          message:
            'Hapus "${item.product.name}"?',
          confirmLabel: 'Hapus',
          confirmColor: AppColors.error,
        );
        if (confirm == true) {
          await notifier.delete(item.product.id);
        }
        break;
    }
  }
}
