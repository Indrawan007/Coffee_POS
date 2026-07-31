import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../domain/models/cart_item_model.dart';
import '../../domain/models/cart_state_model.dart';
import '../providers/cart_provider.dart';
import '../screens/payment_screen.dart';

class CartBottomSheet extends ConsumerWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cartBg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(
                top: AppSizes.sm,
              ),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  const Text(
                    'Pesanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${cart.totalItems} item',
                    style: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                  if (!cart.isEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white60,
                      ),
                      onPressed: () async {
                        final confirm =
                          await AppDialog.confirm(
                            context,
                            title: 'Hapus Pesanan',
                            message: 'Hapus semua item?',
                            confirmColor: AppColors.error,
                          );
                        if (confirm == true) {
                          ref
                            .read(cartNotifierProvider
                              .notifier)
                            .clearCart();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                ],
              ),
            ),

            const Divider(
              color: Colors.white12,
              height: 1,
            ),

            // Items
            Expanded(
              child: cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment:
                        MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 48,
                          color: Colors.white24,
                        ),
                        SizedBox(height: AppSizes.sm),
                        Text(
                          'Belum ada pesanan',
                          style: TextStyle(
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.sm,
                    ),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) =>
                      _CartItemTile(
                        item: cart.items[i],
                      ),
                  ),
            ),

            // Summary + Pay
            if (!cart.isEmpty) ...[
              const Divider(
                color: Colors.white12,
                height: 1,
              ),
              _CartSummary(cart: cart),
              _PayButton(cart: cart),
            ],
          ],
        ),
      ),
    );
  }
}

// ── CART ITEM TILE ─────────────────────────────────
class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
      ref.read(cartNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                    CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (item.addonNames.isNotEmpty)
                      Text(
                        '+ ${item.addonDisplay}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    if (item.note.isNotEmpty)
                      Text(
                        '📝 ${item.note}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => notifier.removeItem(item.id),
                child: const Icon(
                  Icons.close,
                  color: Colors.white38,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              Text(
                CurrencyFormatter.format(
                  item.unitPrice + item.addonPrice,
                ),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              _QtyButton(
                icon: Icons.remove,
                onTap: () => notifier.updateQty(
                  item.id,
                  item.qty - 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                ),
                child: Text(
                  '${item.qty}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _QtyButton(
                icon: Icons.add,
                onTap: () => notifier.updateQty(
                  item.id,
                  item.qty + 1,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                CurrencyFormatter.format(item.totalPrice),
                style: const TextStyle(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
  });
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        AppSizes.radiusFull,
      ),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(
            AppSizes.radiusFull,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── CART SUMMARY ──────────────────────────────────
class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});
  final CartStateModel cart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          _Row('Subtotal',
            CurrencyFormatter.format(cart.subtotal)),
          if (cart.discountAmount > 0)
            _Row(
              'Diskon',
              '-${CurrencyFormatter.format(cart.discountAmount)}',
              color: AppColors.accentLight,
            ),
          if (cart.taxAmount > 0)
            _Row(
              'Pajak (${cart.taxPercent.toInt()}%)',
              '+${CurrencyFormatter.format(cart.taxAmount)}',
            ),
          if (cart.serviceAmount > 0)
            _Row(
              'Service (${cart.servicePercent.toInt()}%)',
              '+${CurrencyFormatter.format(cart.serviceAmount)}',
            ),
          const Divider(color: Colors.white24),
          _Row(
            'TOTAL',
            CurrencyFormatter.format(cart.total),
            isBold: true,
            labelColor: Colors.white,
            valueColor: Colors.white,
            fontSize: 18,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
    this.label,
    this.value, {
    this.isBold = false,
    this.color,
    this.labelColor,
    this.valueColor,
    this.fontSize = 13,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  final Color? labelColor;
  final Color? valueColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor ?? Colors.white60,
              fontWeight: isBold
                ? FontWeight.bold
                : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color ??
                valueColor ??
                Colors.white70,
              fontWeight: isBold
                ? FontWeight.bold
                : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ── PAY BUTTON ────────────────────────────────────
class _PayButton extends StatelessWidget {
  const _PayButton({required this.cart});
  final CartStateModel cart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.md,
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close sheet
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaymentScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.radiusMd,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment),
              const SizedBox(width: AppSizes.sm),
              Text(
                'BAYAR ${CurrencyFormatter.format(cart.total)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}