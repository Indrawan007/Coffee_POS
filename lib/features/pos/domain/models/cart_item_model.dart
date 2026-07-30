import 'package:uuid/uuid.dart';

class CartItemModel {
  CartItemModel({
    String? id,
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.variantName,
    required this.addonIds,
    required this.addonNames,
    required this.addonPrice,
    required this.unitPrice,
    required this.qty,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  final String id;
  final int productId;
  final String productName;
  final int? variantId;
  final String variantName;
  final List<int> addonIds;
  final List<String> addonNames;
  final double addonPrice;
  final double unitPrice;
  int qty;
  String note;

  // Harga per item sudah termasuk addon
  double get totalPrice => (unitPrice + addonPrice) * qty;

  // Display name lengkap
  String get displayName {
    final parts = <String>[productName];
    if (variantName.isNotEmpty) parts.add(variantName);
    return parts.join(' - ');
  }

  String get addonDisplay => addonNames.join(', ');

  CartItemModel copyWith({
    int? qty,
    String? note,
  }) {
    return CartItemModel(
      id: id,
      productId: productId,
      productName: productName,
      variantId: variantId,
      variantName: variantName,
      addonIds: addonIds,
      addonNames: addonNames,
      addonPrice: addonPrice,
      unitPrice: unitPrice,
      qty: qty ?? this.qty,
      note: note ?? this.note,
    );
  }
}