import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:coffee_pos/features/pos/presentation/widgets/cart_botton_sheet.dart';
import 'package:coffee_pos/features/pos/presentation/widgets/category_horizontal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/presentation/providers/category_provider.dart';
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
    final cart = ref.watch(cartNotifierProvider);
    final categoriesAsync =
      ref.watch(activeCategoriesStreamProvider);
    final productsAsync =
      ref.watch(productsWithDetailsProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('☕ Kasir'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop('/dashboard'),
        ),
        actions: [
          // Cart badge - hanya tampil di mode compact
          if (!isWide && !cart.isEmpty)
            _CartBadge(
              totalItems: cart.totalItems,
              total: cart.total,
              onTap: () => _showCartSheet(context),
            ),

          // Cart badge di mode wide
          if (isWide)
            _CartBadgeSmall(totalItems: cart.totalItems),
        ],
      ),

      // ── BODY ───────────────────────────────
      body: isWide
        ? _WideLayout(
            selectedCategoryId: _selectedCategoryId,
            searchQuery: _searchQuery,
            searchCtrl: _searchCtrl,
            onCategorySelect: (id) => setState(
              () => _selectedCategoryId = id,
            ),
            onSearchChanged: (val) => setState(
              () => _searchQuery = val,
            ),
            onSearchClear: () {
              _searchCtrl.clear();
              setState(() => _searchQuery = '');
            },
          )
        : _CompactLayout(
            selectedCategoryId: _selectedCategoryId,
            searchQuery: _searchQuery,
            searchCtrl: _searchCtrl,
            onCategorySelect: (id) => setState(
              () => _selectedCategoryId = id,
            ),
            onSearchChanged: (val) => setState(
              () => _searchQuery = val,
            ),
            onSearchClear: () {
              _searchCtrl.clear();
              setState(() => _searchQuery = '');
            },
          ),

      // ── FAB untuk cart di mode compact ──────
      floatingActionButton: !isWide && !cart.isEmpty
        ? FloatingActionButton.extended(
            onPressed: () => _showCartSheet(context),
            backgroundColor: AppColors.accent,
            icon: const Icon(Icons.shopping_cart),
            label: Text(
              '${cart.totalItems} item • '
              '${CurrencyFormatter.format(cart.total)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : null,
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CartBottomSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════
// WIDE LAYOUT (Tablet Landscape ≥ 900dp)
// ═══════════════════════════════════════════════════
class _WideLayout extends ConsumerWidget {
  const _WideLayout({
    required this.selectedCategoryId,
    required this.searchQuery,
    required this.searchCtrl,
    required this.onCategorySelect,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  final int? selectedCategoryId;
  final String searchQuery;
  final TextEditingController searchCtrl;
  final void Function(int?) onCategorySelect;
  final void Function(String) onSearchChanged;
  final VoidCallback onSearchClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync =
      ref.watch(activeCategoriesStreamProvider);
    final productsAsync =
      ref.watch(productsWithDetailsProvider);

    return Row(
      children: [
        // ── KIRI: Kategori ──────────────────
        categoriesAsync.when(
          loading: () => const SizedBox(
            width: AppSizes.categoryWidth,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => const SizedBox(
            width: AppSizes.categoryWidth,
          ),
          data: (categories) => CategoryTab(
            categories: categories,
            selectedId: selectedCategoryId,
            onSelect: onCategorySelect,
          ),
        ),

        // ── TENGAH: Produk ──────────────────
        Expanded(
          child: Column(
            children: [
              _SearchBar(
                controller: searchCtrl,
                query: searchQuery,
                onChanged: onSearchChanged,
                onClear: onSearchClear,
              ),
              Expanded(
                child: _ProductSection(
                  selectedCategoryId: selectedCategoryId,
                  searchQuery: searchQuery,
                ),
              ),
            ],
          ),
        ),

        // ── KANAN: Cart ─────────────────────
        const CartPanel(),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// COMPACT LAYOUT (Phone / Tablet Portrait < 900dp)
// ═══════════════════════════════════════════════════
class _CompactLayout extends ConsumerWidget {
  const _CompactLayout({
    required this.selectedCategoryId,
    required this.searchQuery,
    required this.searchCtrl,
    required this.onCategorySelect,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  final int? selectedCategoryId;
  final String searchQuery;
  final TextEditingController searchCtrl;
  final void Function(int?) onCategorySelect;
  final void Function(String) onSearchChanged;
  final VoidCallback onSearchClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync =
      ref.watch(activeCategoriesStreamProvider);

    return Column(
      children: [
        // ── SEARCH BAR ──────────────────────
        _SearchBar(
          controller: searchCtrl,
          query: searchQuery,
          onChanged: onSearchChanged,
          onClear: onSearchClear,
        ),

        // ── KATEGORI HORIZONTAL ─────────────
        categoriesAsync.when(
          loading: () => const SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => const SizedBox.shrink(),
          data: (categories) => CategoryHorizontal(
            categories: categories,
            selectedId: selectedCategoryId,
            onSelect: onCategorySelect,
          ),
        ),

        // ── PRODUK GRID ─────────────────────
        Expanded(
          child: _ProductSection(
            selectedCategoryId: selectedCategoryId,
            searchQuery: searchQuery,
            compact: true,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════

// ── SEARCH BAR ────────────────────────────────────
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
    return Padding(
      padding: const EdgeInsets.all(AppSizes.sm),
      child: TextField(
        controller: controller,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ── PRODUCT SECTION ───────────────────────────────
class _ProductSection extends ConsumerWidget {
  const _ProductSection({
    required this.selectedCategoryId,
    required this.searchQuery,
    this.compact = false,
  });

  final int? selectedCategoryId;
  final String searchQuery;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync =
      ref.watch(productsWithDetailsProvider);

    return productsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e'),
      ),
      data: (products) {
        var filtered = products
          .where((p) => p.product.isActive)
          .toList();

        if (selectedCategoryId != null) {
          filtered = filtered
            .where((p) =>
              p.product.categoryId == selectedCategoryId,
            )
            .toList();
        }

        if (searchQuery.isNotEmpty) {
          filtered = filtered
            .where((p) => p.product.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()),
            )
            .toList();
        }

        return ProductGrid(
          products: filtered,
          compact: compact,
        );
      },
    );
  }
}

// ── CART BADGE (Compact Mode) ─────────────────────
class _CartBadge extends StatelessWidget {
  const _CartBadge({
    required this.totalItems,
    required this.total,
    required this.onTap,
  });

  final int totalItems;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              '$totalItems',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CART BADGE SMALL (Wide Mode) ──────────────────
class _CartBadgeSmall extends StatelessWidget {
  const _CartBadgeSmall({required this.totalItems});
  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '$totalItems item',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}