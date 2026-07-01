import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// A single line item in the cart.
@immutable
class CartLine {
  const CartLine({
    required this.menuItemId,
    required this.itemName,
    required this.price,
    this.quantity = 1,
  });

  final String menuItemId;
  final String itemName;
  final Decimal price;
  final int quantity;

  /// Line total: `price * quantity`.
  Decimal get lineTotal => price * Decimal.fromInt(quantity);

  CartLine copyWith({int? quantity}) {
    return CartLine(
      menuItemId: menuItemId,
      itemName: itemName,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartLine &&
          runtimeType == other.runtimeType &&
          menuItemId == other.menuItemId;

  @override
  int get hashCode => menuItemId.hashCode;
}

/// The customer's shopping cart.
///
/// Enforces the single-restaurant invariant: all items must belong to the
/// same restaurant. Adding an item from a different restaurant clears the
/// cart first.
@immutable
class Cart {
  const Cart({
    this.restaurantId,
    this.restaurantName,
    this.lines = const [],
  });

  /// The restaurant that items belong to, or `null` if the cart is empty.
  final String? restaurantId;

  /// The restaurant's display name.
  final String? restaurantName;

  /// The items in the cart.
  final List<CartLine> lines;

  /// Whether the cart is empty.
  bool get isEmpty => lines.isEmpty;

  /// Total number of items (sum of all line quantities).
  int get totalItems =>
      lines.fold(0, (sum, line) => sum + line.quantity);

  /// Subtotal: sum of all line totals.
  Decimal get subtotal =>
      lines.fold(Decimal.zero, (sum, line) => sum + line.lineTotal);

  Cart copyWith({
    String? restaurantId,
    String? restaurantName,
    List<CartLine>? lines,
    bool clearRestaurant = false,
  }) {
    return Cart(
      restaurantId: clearRestaurant ? null : (restaurantId ?? this.restaurantId),
      restaurantName:
          clearRestaurant ? null : (restaurantName ?? this.restaurantName),
      lines: lines ?? this.lines,
    );
  }
}
