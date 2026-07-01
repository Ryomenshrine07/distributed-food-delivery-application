import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// Domain entity for a single item within an order.
@immutable
class OrderItem {
  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  final String id;
  final String menuItemId;
  final String itemName;
  final Decimal price;
  final int quantity;
  final Decimal totalPrice;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'OrderItem(id: $id, itemName: $itemName, qty: $quantity, total: $totalPrice)';
}
