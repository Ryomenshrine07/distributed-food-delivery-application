import 'package:decimal/decimal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/cart.dart';

part 'cart_controller.g.dart';

/// Controller for the shopping cart.
///
/// Kept-alive so the cart persists across screen navigations.
/// Enforces the single-restaurant invariant: adding from a different
/// restaurant clears the current cart.
@Riverpod(keepAlive: true)
class CartController extends _$CartController {
  @override
  Cart build() => const Cart();

  /// Adds an item to the cart, or increments its quantity if already present.
  ///
  /// If the [restaurantId] differs from the current cart's restaurant, the
  /// cart is cleared first (single-restaurant invariant).
  void addItem({
    required String restaurantId,
    required String restaurantName,
    required String menuItemId,
    required String itemName,
    required Decimal price,
    int quantity = 1,
  }) {
    Cart currentCart = state;

    // Single-restaurant invariant.
    if (currentCart.restaurantId != null &&
        currentCart.restaurantId != restaurantId) {
      currentCart = const Cart();
    }

    final existingIndex =
        currentCart.lines.indexWhere((l) => l.menuItemId == menuItemId);
    final updatedLines = List<CartLine>.from(currentCart.lines);

    if (existingIndex >= 0) {
      // Increment quantity.
      final existing = updatedLines[existingIndex];
      updatedLines[existingIndex] =
          existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      // Add new line.
      updatedLines.add(CartLine(
        menuItemId: menuItemId,
        itemName: itemName,
        price: price,
        quantity: quantity,
      ));
    }

    state = Cart(
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      lines: updatedLines,
    );
  }

  /// Sets the quantity of a specific item. Removes the item if [quantity] ≤ 0.
  void setQuantity(String menuItemId, int quantity) {
    final updatedLines = List<CartLine>.from(state.lines);
    final index = updatedLines.indexWhere((l) => l.menuItemId == menuItemId);
    if (index < 0) return;

    if (quantity <= 0) {
      updatedLines.removeAt(index);
    } else {
      updatedLines[index] = updatedLines[index].copyWith(quantity: quantity);
    }

    if (updatedLines.isEmpty) {
      state = const Cart();
    } else {
      state = state.copyWith(lines: updatedLines);
    }
  }

  /// Removes an item from the cart entirely.
  void removeItem(String menuItemId) {
    setQuantity(menuItemId, 0);
  }

  /// Clears the entire cart.
  void clearCart() {
    state = const Cart();
  }
}
