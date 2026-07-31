import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/models/cart_item_model.dart';
import '../../domain/models/cart_state_model.dart';

part 'cart_provider.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {

  @override
  CartStateModel build() {
    // Load tax & service dari settings
    _loadSettings();
    return CartStateModel.empty;
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ref
        .read(settingsDatasourceProvider)
        .getSettings();

      if (settings != null) {
        state = state.copyWith(
          taxPercent: settings.taxPercent,
          servicePercent: settings.servicePercent,
        );
      }
    } catch (_) {}
  }

  // ─── ADD ITEM ──────────────────────────────────
  void addItem(CartItemModel item) {
    final items = state.items.toList();

    // Cek apakah item sama sudah ada
    // Sama = product + variant + addons sama
    final existingIdx = items.indexWhere((i) =>
      i.productId == item.productId &&
      i.variantId == item.variantId &&
      _sameAddons(i.addonIds, item.addonIds),
    );

    if (existingIdx >= 0) {
      // Tambah qty
      items[existingIdx] = items[existingIdx].copyWith(
        qty: items[existingIdx].qty + item.qty,
      );
    } else {
      items.add(item);
    }

    state = state.copyWith(items: items);
  }

  // ─── REMOVE ITEM ───────────────────────────────
  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items
        .where((i) => i.id != itemId)
        .toList(),
    );
  }

  // ─── UPDATE QTY ────────────────────────────────
  void updateQty(String itemId, int qty) {
    if (qty <= 0) {
      removeItem(itemId);
      return;
    }

    final items = state.items.toList();
    final idx   = items.indexWhere((i) => i.id == itemId);

    if (idx >= 0) {
      items[idx] = items[idx].copyWith(qty: qty);
      state = state.copyWith(items: items);
    }
  }

  // ─── UPDATE NOTE ───────────────────────────────
  void updateNote(String itemId, String note) {
    final items = state.items.toList();
    final idx   = items.indexWhere((i) => i.id == itemId);

    if (idx >= 0) {
      items[idx] = items[idx].copyWith(note: note);
      state = state.copyWith(items: items);
    }
  }

  // ─── APPLY DISCOUNT ────────────────────────────
  void applyDiscount(DiscountType type, double value) {
    state = state.copyWith(
      discountType: type,
      discountValue: value,
    );
  }

  void clearDiscount() {
    state = state.copyWith(
      discountType: DiscountType.nominal,
      discountValue: 0,
    );
  }

  // ─── CLEAR CART ────────────────────────────────
  void clearCart() {
    final taxPercent     = state.taxPercent;
    final servicePercent = state.servicePercent;
    state = CartStateModel.empty.copyWith(
      taxPercent: taxPercent,
      servicePercent: servicePercent,
    );
  }

  // ─── HELPER ────────────────────────────────────
  bool _sameAddons(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    final sortedA = [...a]..sort();
    final sortedB = [...b]..sort();
    for (var i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }
}