import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:coffee_pos/features/pos/presentation/bottomsheets/variant_addon_bottonmsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../products/data/datasources/product_datasource.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({
    super.key,
    required this.products,
    this.compact = false,
  });

  final List<ProductWithDetails> products;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const EmptyState(
        message: 'Tidak ada produk',
        icon: Icons.coffee_outlined,
      );
    }

    // ✅ Responsive: hitung kolom berdasarkan lebar
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(
      screenWidth,
      compact,
    );

    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.sm),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSizes.sm,
        mainAxisSpacing: AppSizes.sm,
        childAspectRatio: compact ? 0.75 : 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => _ProductCard(
        item: products[i],
        compact: compact,
      ),
    );
  }

  int _getCrossAxisCount(double width, bool compact) {
    if (compact) {
      // Mode compact (tanpa sidebar)
      if (width < 400) return 2;
      if (width < 600) return 3;
      if (width < 900) return 4;
      return 5;
    } else {
      // Mode wide (sudah dikurangi sidebar + cart)
      // Area tengah kira-kira width - 120 - 320
      final available = width - 120 - 320;
      if (available < 300) return 2;
      if (available < 500) return 3;
      if (available < 700) return 4;
      return 5;
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    this.compact = false,
  });

  final ProductWithDetails item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final product  = item.product;
    final isActive = product.isActive;

    return InkWell(
      onTap: isActive ? () => _onTap(context) : null,
      borderRadius: BorderRadius.circular(
        AppSizes.radiusMd,
      ),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppSizes.radiusMd,
            ),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image / Icon
              Expanded(
                flex: compact ? 2 : 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusMd),
                  ),
                  child: product.imagePath != null
                    ? Image.asset(
                        product.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                          _defaultIcon(),
                      )
                    : _defaultIcon(),
                ),
              ),

              // Info
              Padding(
                padding: EdgeInsets.all(
                  compact ? AppSizes.xs : AppSizes.sm,
                ),
                child: Column(
                  crossAxisAlignment:
                    CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: compact ? 12 : 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(
                        product.basePrice,
                      ),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: compact ? 11 : 12,
                      ),
                    ),
                    // Varian info
                    if (item.variants.isNotEmpty &&
                        !compact)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                        ),
                        child: Text(
                          item.variants
                            .map((v) => v.name)
                            .join(' • '),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (!isActive)
                      Container(
                        margin: const EdgeInsets.only(
                          top: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error
                            .withOpacity(0.1),
                          borderRadius:
                            BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Habis',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultIcon() {
    return Container(
      color: AppColors.primary.withOpacity(0.08),
      child: Icon(
        Icons.coffee,
        size: compact ? 32 : 40,
        color: AppColors.primary,
      ),
    );
  }

  void _onTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VariantAddonBottomSheet(item: item),
    );
  }
}