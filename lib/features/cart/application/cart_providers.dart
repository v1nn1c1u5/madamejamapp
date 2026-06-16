import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cart_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void add(CartItem item) {
    final idx = state.indexWhere((e) => e.sku.id == item.sku.id);
    if (idx >= 0) {
      final existing = state[idx];
      state = [
        ...state.sublist(0, idx),
        existing.copyWith(quantity: existing.quantity + item.quantity),
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [...state, item];
    }
  }

  void updateQuantity(String skuId, int quantity) {
    if (quantity <= 0) {
      remove(skuId);
      return;
    }
    state = [
      for (final item in state)
        if (item.sku.id == skuId) item.copyWith(quantity: quantity) else item,
    ];
  }

  void remove(String skuId) {
    state = state.where((e) => e.sku.id != skuId).toList();
  }

  void clear() => state = [];
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>(
  (_) => CartNotifier(),
);

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold(0, (sum, item) => sum + item.quantity);
});

/// Retorna os IDs de produto que não atingiram o mínimo por pedido.
final cartProductMinViolationsProvider = Provider<List<String>>((ref) {
  final items = ref.watch(cartProvider);
  final byProduct = <String, ({String name, int minQty, int totalQty})>{};
  for (final item in items) {
    final current = byProduct[item.productId];
    byProduct[item.productId] = (
      name: item.productName,
      minQty: item.productMinQuantity,
      totalQty: (current?.totalQty ?? 0) + item.quantity,
    );
  }
  return [
    for (final entry in byProduct.entries)
      if (entry.value.totalQty < entry.value.minQty) entry.key,
  ];
});
