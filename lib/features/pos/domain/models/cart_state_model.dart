import 'cart_item_model.dart';

enum DiscountType { nominal, percent }

class CartStateModel {
  const CartStateModel({
    this.items = const [],
    this.discountType = DiscountType.nominal,
    this.discountValue = 0,
    this.taxPercent = 0,
    this.servicePercent = 0,
  });

  final List<CartItemModel> items;
  final DiscountType discountType;
  final double discountValue;
  final double taxPercent;
  final double servicePercent;

  // ─── KALKULASI ────────────────────────────────
  double get subtotal =>
    items.fold(0, (sum, i) => sum + i.totalPrice);

  double get discountAmount {
    if (discountType == DiscountType.percent) {
      return subtotal * (discountValue / 100);
    }
    return discountValue;
  }

  double get afterDiscount => subtotal - discountAmount;

  double get taxAmount =>
    afterDiscount * (taxPercent / 100);

  double get serviceAmount =>
    afterDiscount * (servicePercent / 100);

  double get total =>
    afterDiscount + taxAmount + serviceAmount;

  bool get isEmpty => items.isEmpty;

  int get totalItems =>
    items.fold(0, (sum, i) => sum + i.qty);

  // ─── COPY WITH ────────────────────────────────
  CartStateModel copyWith({
    List<CartItemModel>? items,
    DiscountType? discountType,
    double? discountValue,
    double? taxPercent,
    double? servicePercent,
  }) {
    return CartStateModel(
      items: items ?? this.items,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      taxPercent: taxPercent ?? this.taxPercent,
      servicePercent: servicePercent ?? this.servicePercent,
    );
  }

  // ─── EMPTY ────────────────────────────────────
  static const empty = CartStateModel();
}