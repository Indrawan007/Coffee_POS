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
  const VariantAddonBottomSheet({super.key, required this.item});
  final ProductWithDetails item;

  @override
  ConsumerState<VariantAddonBottomSheet> createState() =>
    _VariantAddonBottomSheetState();
}

class _VariantAddonBottomSheetState
    extends ConsumerState<VariantAddonBottomSheet> {

  ProductVariantsTableData? _selectedVariant;
  final Set<int>    _selectedAddonIds   = {};
  final Map<int, AddonsTableData> _addonMap = {};
  int    _qty  = 1;
  String _note = '';
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default pilih varian pertama
    if (widget.item.variants.isNotEmpty) {
      _selectedVariant = widget.item.variants.first;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  double get _totalPrice {
    final base    = widget.item.product.basePrice;
    final variant = _selectedVariant?.priceAdjustment ?? 0;
    final addons  = _addonMap.entries
      .where((e) => _selectedAddonIds.contains(e.key))
      .fold(0.0, (sum, e) => sum + e.value.price);
    return (base + variant + addons) * _qty;
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
      addonNames: selectedAddons.map((e) => e.value.name).toList(),
      addonPrice: _addonPrice,
      unitPrice: _unitPrice,
      qty: _qty,
      note: _noteCtrl.text.trim(),
    );

    ref.read(cartNotifierProvider.notifier).addItem(item);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.displayName} ditambahkan'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addonsAsync = ref.watch(activeAddonsProvider);
    final product     = widget.item.product;
    final variants    = widget.item.variants;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: AppSizes.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                            CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(
                                product.basePrice,
                              ),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const Divider(height: AppSizes.lg),

                  // ── VARIAN ──────────────────────
                  if (variants.isNotEmpty) ...[
                    const Text(
                      'Pilih Size / Varian',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Wrap(
                      spacing: AppSizes.sm,
                      children: variants.map((v) {
                        final isSelected =
                          _selectedVariant?.id == v.id;
                        return ChoiceChip(
                          label: Text(
                            '${v.name}'
                            '${v.priceAdjustment > 0
                              ? ' (+${CurrencyFormatter.format(v.priceAdjustment)})'
                              : ''
                            }',
                          ),
                          selected: isSelected,
                          selectedColor:
                            AppColors.primary.withOpacity(0.2),
                          onSelected: (_) => setState(
                            () => _selectedVariant = v,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],

                  // ── ADD-ON ──────────────────────
                  addonsAsync.when(
                    loading: () =>
                      const CircularProgressIndicator(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (addons) {
                      // Simpan ke map
                      for (final a in addons) {
                        _addonMap[a.id] = a;
                      }

                      return Column(
                        crossAxisAlignment:
                          CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add-on (opsional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          ...addons.map((a) => CheckboxListTile(
                            dense: true,
                            title: Text(a.name),
                            subtitle: a.price > 0
                              ? Text(
                                  '+${CurrencyFormatter.format(a.price)}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                            value: _selectedAddonIds
                              .contains(a.id),
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() {
                              if (val == true) {
                                _selectedAddonIds.add(a.id);
                              } else {
                                _selectedAddonIds.remove(a.id);
                              }
                            }),
                          )),
                          const SizedBox(height: AppSizes.md),
                        ],
                      );
                    },
                  ),

                  // ── CATATAN ─────────────────────
                  const Text(
                    'Catatan (opsional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: less ice, no whip...',
                    ),
                    onChanged: (v) =>
                      setState(() => _note = v),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // ── QTY ─────────────────────────
                  Row(
                    mainAxisAlignment:
                      MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _qty > 1
                          ? () => setState(() => _qty--)
                          : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                        iconSize: 32,
                        color: AppColors.primary,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.lg,
                        ),
                        child: Text(
                          '$_qty',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                          setState(() => _qty++),
                        icon: const Icon(
                          Icons.add_circle_outline,
                        ),
                        iconSize: 32,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── BOTTOM: Harga + Tambah ───────────
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment:
                        CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(_totalPrice),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addToCart,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Tambah ke Pesanan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(
                            double.infinity, 52,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}