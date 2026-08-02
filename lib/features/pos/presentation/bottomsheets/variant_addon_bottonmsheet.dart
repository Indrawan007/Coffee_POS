import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../products/data/datasources/product_datasource.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../domain/models/cart_item_model.dart';
import '../providers/cart_provider.dart';

class VariantAddonBottomSheet extends ConsumerStatefulWidget {
  const VariantAddonBottomSheet({
    super.key,
    required this.item,
  });
  final ProductWithDetails item;

  @override
  ConsumerState<VariantAddonBottomSheet> createState() =>
    _VariantAddonBottomSheetState();
}

class _VariantAddonBottomSheetState
    extends ConsumerState<VariantAddonBottomSheet> {

  ProductVariantsTableData? _selectedVariant;
  final Set<int> _selectedAddonIds = {};
  final Map<int, AddonsTableData> _addonMap = {};
  int _qty = 1;
  final _noteCtrl = TextEditingController();
  bool _showNote = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.variants.isNotEmpty) {
      _selectedVariant = widget.item.variants.first;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  double get _unitPrice {
    return widget.item.product.basePrice +
      (_selectedVariant?.priceAdjustment ?? 0);
  }

  double get _addonPrice {
    return _addonMap.entries
      .where((e) => _selectedAddonIds.contains(e.key))
      .fold(0.0, (sum, e) => sum + e.value.price);
  }

  double get _totalPrice {
    return (_unitPrice + _addonPrice) * _qty;
  }

  void _addToCart() {
    final selectedAddons = _addonMap.entries
      .where((e) => _selectedAddonIds.contains(e.key))
      .toList();

    final item = CartItemModel(
      productId: widget.item.product.id,
      productName: widget.item.product.name,
      variantId: _selectedVariant?.id,
      variantName: _selectedVariant?.name ?? '',
      addonIds: selectedAddons.map((e) => e.key).toList(),
      addonNames: selectedAddons
        .map((e) => e.value.name).toList(),
      addonPrice: _addonPrice,
      unitPrice: _unitPrice,
      qty: _qty,
      note: _noteCtrl.text.trim(),
    );

    ref.read(cartNotifierProvider.notifier).addItem(item);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${item.displayName} x$_qty ditambahkan',
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSizes.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.radiusMd,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product    = widget.item.product;
    final variants   = widget.item.variants;
    final categoryId = product.categoryId;

    final addonsAsync = ref.watch(
      addonsByCategoryProvider(categoryId),
    );

    final screenHeight = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      initialChildSize: screenHeight < 700 ? 0.9 : 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
        child: Column(
          children: [
            // ── HANDLE ────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                  top: AppSizes.sm,
                ),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── SCROLLABLE CONTENT ────────────
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  AppSizes.sm,
                  AppSizes.md,
                  0,
                ),
                child: Column(
                  crossAxisAlignment:
                    CrossAxisAlignment.start,
                  children: [
                    // ── PRODUCT HEADER ─────────
                    _ProductHeader(
                      product: product,
                      category: widget.item.category,
                      onClose: () =>
                        Navigator.pop(context),
                    ),

                    // ── VARIANT SECTION ────────
                    if (variants.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.md),
                      _VariantSection(
                        variants: variants,
                        selectedVariant: _selectedVariant,
                        onSelect: (v) => setState(
                          () => _selectedVariant = v,
                        ),
                      ),
                    ],

                    // ── ADDON SECTION ──────────
                    addonsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(
                          AppSizes.md,
                        ),
                        child: Center(
                          child:
                            CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, __) =>
                        const SizedBox.shrink(),
                      data: (addons) {
                        if (addons.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        for (final a in addons) {
                          _addonMap[a.id] = a;
                        }

                        // Pisahkan addon gratis & berbayar
                        final freeAddons = addons
                          .where((a) => a.price <= 0)
                          .toList();
                        final paidAddons = addons
                          .where((a) => a.price > 0)
                          .toList();

                        return Column(
                          crossAxisAlignment:
                            CrossAxisAlignment.start,
                          children: [
                            if (paidAddons.isNotEmpty) ...[
                              const SizedBox(
                                height: AppSizes.md,
                              ),
                              _AddonSection(
                                title: 'Tambahan',
                                addons: paidAddons,
                                selectedIds:
                                  _selectedAddonIds,
                                onToggle: (id) =>
                                  setState(() {
                                    if (_selectedAddonIds
                                        .contains(id)) {
                                      _selectedAddonIds
                                        .remove(id);
                                    } else {
                                      _selectedAddonIds
                                        .add(id);
                                    }
                                  }),
                              ),
                            ],
                            if (freeAddons.isNotEmpty) ...[
                              const SizedBox(
                                height: AppSizes.md,
                              ),
                              _AddonSection(
                                title: 'Kustomisasi',
                                addons: freeAddons,
                                selectedIds:
                                  _selectedAddonIds,
                                onToggle: (id) =>
                                  setState(() {
                                    if (_selectedAddonIds
                                        .contains(id)) {
                                      _selectedAddonIds
                                        .remove(id);
                                    } else {
                                      _selectedAddonIds
                                        .add(id);
                                    }
                                  }),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    // ── NOTE SECTION ──────────
                    const SizedBox(height: AppSizes.md),
                    _NoteSection(
                      controller: _noteCtrl,
                      isExpanded: _showNote,
                      onToggle: () => setState(
                        () => _showNote = !_showNote,
                      ),
                    ),

                    // ── QTY SECTION ───────────
                    const SizedBox(height: AppSizes.md),
                    _QtySection(
                      qty: _qty,
                      onDecrement: _qty > 1
                        ? () => setState(() => _qty--)
                        : null,
                      onIncrement: () =>
                        setState(() => _qty++),
                    ),

                    // Spacer for bottom bar
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),

            // ── STICKY BOTTOM BAR ─────────────
            _BottomBar(
              totalPrice: _totalPrice,
              qty: _qty,
              onAdd: _addToCart,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// PRODUCT HEADER
// ═══════════════════════════════════════════════════
class _ProductHeader extends StatelessWidget {
  const _ProductHeader({
    required this.product,
    required this.category,
    required this.onClose,
  });

  final ProductsTableData product;
  final CategoriesTableData category;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              AppSizes.radiusMd,
            ),
          ),
          child: product.imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppSizes.radiusMd,
                ),
                child: Image.asset(
                  product.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                    const Icon(
                      Icons.coffee,
                      size: 36,
                      color: AppColors.primary,
                    ),
                ),
              )
            : const Icon(
                Icons.coffee,
                size: 36,
                color: AppColors.primary,
              ),
        ),

        const SizedBox(width: AppSizes.md),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary
                    .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppSizes.radiusFull,
                  ),
                ),
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mulai ${CurrencyFormatter.format(product.basePrice)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Close
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.border,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          onPressed: onClose,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// VARIANT SECTION - Horizontal scrollable cards
// ═══════════════════════════════════════════════════
class _VariantSection extends StatelessWidget {
  const _VariantSection({
    required this.variants,
    required this.selectedVariant,
    required this.onSelect,
  });

  final List<ProductVariantsTableData> variants;
  final ProductVariantsTableData? selectedVariant;
  final void Function(ProductVariantsTableData) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(
          icon: Icons.straighten,
          label: 'Pilih Varian',
          required: true,
        ),
        const SizedBox(height: AppSizes.sm),

        // ✅ Horizontal scroll row
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: variants.length,
            separatorBuilder: (_, __) =>
              const SizedBox(width: AppSizes.sm),
            itemBuilder: (ctx, i) {
              final v = variants[i];
              final isSelected =
                selectedVariant?.id == v.id;

              return GestureDetector(
                onTap: () => onSelect(v),
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  width: 100,
                  padding: const EdgeInsets.all(
                    AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusMd,
                    ),
                    border: Border.all(
                      color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary
                              .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                  ),
                  child: Column(
                    mainAxisAlignment:
                      MainAxisAlignment.center,
                    children: [
                      Text(
                        v.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        v.priceAdjustment > 0
                          ? '+${CurrencyFormatter.format(v.priceAdjustment)}'
                          : 'Standar',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                            ? Colors.white70
                            : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// ADDON SECTION - Wrap chips (compact, no scroll)
// ═══════════════════════════════════════════════════
class _AddonSection extends StatelessWidget {
  const _AddonSection({
    required this.title,
    required this.addons,
    required this.selectedIds,
    required this.onToggle,
  });

  final String title;
  final List<AddonsTableData> addons;
  final Set<int> selectedIds;
  final void Function(int) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          icon: addons.first.price > 0
            ? Icons.add_circle_outline
            : Icons.tune,
          label: title,
        ),
        const SizedBox(height: AppSizes.sm),

        // ✅ Wrap chips - semua terlihat tanpa scroll
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: addons.map((addon) {
            final isSelected =
              selectedIds.contains(addon.id);

            return GestureDetector(
              onTap: () => onToggle(addon.id),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surfaceVar,
                  borderRadius: BorderRadius.circular(
                    AppSizes.radiusFull,
                  ),
                  border: Border.all(
                    color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Check icon
                    AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                            ? AppColors.primary
                            : AppColors.textHint,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                    ),

                    const SizedBox(width: 8),

                    // Name
                    Text(
                      addon.name,
                      style: TextStyle(
                        fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                        fontSize: 13,
                        color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      ),
                    ),

                    // Price
                    if (addon.price > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding:
                          const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                        decoration: BoxDecoration(
                          color: isSelected
                            ? AppColors.primary
                                .withOpacity(0.2)
                            : AppColors.border
                                .withOpacity(0.5),
                          borderRadius:
                            BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${CurrencyFormatter.format(addon.price)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// NOTE SECTION - Collapsible
// ═══════════════════════════════════════════════════
class _NoteSection extends StatelessWidget {
  const _NoteSection({
    required this.controller,
    required this.isExpanded,
    required this.onToggle,
  });

  final TextEditingController controller;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle button
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVar,
              borderRadius: BorderRadius.circular(
                AppSizes.radiusMd,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.note_add_outlined,
                  size: 18,
                  color: isExpanded
                    ? AppColors.primary
                    : AppColors.textHint,
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  controller.text.isNotEmpty
                    ? 'Catatan: ${controller.text}'
                    : 'Tambah catatan...',
                  style: TextStyle(
                    color: controller.text.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Icon(
                  isExpanded
                    ? Icons.expand_less
                    : Icons.expand_more,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expandable input
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(
              top: AppSizes.sm,
            ),
            child: TextField(
              controller: controller,
              maxLines: 2,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Contoh: less ice, extra hot...',
                hintStyle: const TextStyle(fontSize: 13),
                contentPadding: const EdgeInsets.all(
                  AppSizes.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.radiusSm,
                  ),
                ),
              ),
            ),
          ),
          crossFadeState: isExpanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// QTY SECTION
// ═══════════════════════════════════════════════════
class _QtySection extends StatelessWidget {
  const _QtySection({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int qty;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVar,
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
      ),
      child: Row(
        children: [
          const _SectionLabel(
            icon: Icons.shopping_bag_outlined,
            label: 'Jumlah',
          ),
          const Spacer(),

          // Decrement
          _CircleButton(
            icon: Icons.remove,
            onTap: onDecrement,
            enabled: onDecrement != null,
          ),

          // Qty display
          Container(
            width: 56,
            alignment: Alignment.center,
            child: Text(
              '$qty',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Increment
          _CircleButton(
            icon: Icons.add,
            onTap: onIncrement,
            enabled: true,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
            ? AppColors.primary
            : AppColors.border,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled
            ? Colors.white
            : AppColors.textHint,
          size: 20,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// BOTTOM BAR - Sticky
// ═══════════════════════════════════════════════════
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.totalPrice,
    required this.qty,
    required this.onAdd,
  });

  final double totalPrice;
  final int qty;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total price
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment:
                  CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(totalPrice),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSizes.md),

            // Add button
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMd,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                      MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_shopping_cart,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tambah ($qty)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.label,
    this.required = false,
  });

  final IconData icon;
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
