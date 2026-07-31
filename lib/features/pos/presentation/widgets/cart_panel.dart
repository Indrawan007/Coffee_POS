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

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartNotifierProvider);

      // ✅ Responsive width
      final screenWidth = MediaQuery.of(context).size.width;
      final cartWidth = screenWidth > 1200
      ? 360.0
      : screenWidth > 900
        ? 300.0
        : 280.0;

    return Container(
      width: cartWidth, 
      color: AppColors.cartBg,
      child: Column(
        children: [
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!cart.isEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white60,
                    ),
                    tooltip: 'Hapus semua',
                    onPressed: () async {
                      final confirm = await AppDialog.confirm(
                        context,
                        title: 'Hapus Pesanan',
                        message: 'Hapus semua item?',
                        confirmColor: AppColors.error,
                      );
                      if (confirm == true) {
                        ref
                          .read(cartNotifierProvider.notifier)
                          .clearCart();
                      }
                    },
                  ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Cart items
          Expanded(
            child: cart.isEmpty
              ? const _EmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.sm,
                  ),
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) =>
                    _CartItemTile(item: cart.items[i]),
                ),
          ),

          // Summary & Pay
          if (!cart.isEmpty) ...[
            const Divider(color: Colors.white12, height: 1),
            _CartSummary(cart: cart),
            _PayButton(cart: cart),
          ],
        ],
      ),
    );
  }
}

// ─── EMPTY CART ────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 48,
            color: Colors.white24,
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'Belum ada pesanan',
            style: TextStyle(color: Colors.white38),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'Pilih produk untuk mulai',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CART ITEM TILE ────────────────────────────────
class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (item.addonNames.isNotEmpty)
                      Text(
                        '+ ${item.addonDisplay}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
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

              // Delete
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
              // Price
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

              // Qty controls
              Row(
                children: [
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
                ],
              ),

              const SizedBox(width: AppSizes.sm),

              // Total
              Text(
                CurrencyFormatter.format(item.totalPrice),
                style: const TextStyle(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
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
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

// ─── CART SUMMARY ──────────────────────────────────
class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});
  final CartStateModel cart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: CurrencyFormatter.format(cart.subtotal),
          ),
          if (cart.discountAmount > 0)
            _SummaryRow(
              label: 'Diskon',
              value: '-${CurrencyFormatter.format(cart.discountAmount)}',
              valueColor: AppColors.accentLight,
            ),
          if (cart.taxAmount > 0)
            _SummaryRow(
              label: 'Pajak (${cart.taxPercent.toInt()}%)',
              value: '+${CurrencyFormatter.format(cart.taxAmount)}',
            ),
          if (cart.serviceAmount > 0)
            _SummaryRow(
              label: 'Service (${cart.servicePercent.toInt()}%)',
              value: '+${CurrencyFormatter.format(cart.serviceAmount)}',
            ),
          const Divider(color: Colors.white24),
          _SummaryRow(
            label: 'TOTAL',
            value: CurrencyFormatter.format(cart.total),
            isBold: true,
            valueColor: Colors.white,
            labelColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.labelColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final Color? labelColor;

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
              fontSize: isBold ? 16 : 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white70,
              fontWeight: isBold
                ? FontWeight.bold
                : FontWeight.normal,
              fontSize: isBold ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PAY BUTTON ────────────────────────────────────
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
      child: ElevatedButton(
        onPressed: () => _onPay(context),
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
    );
  }

  void _onPay(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentScreen(),
      ),
    );
  }
}