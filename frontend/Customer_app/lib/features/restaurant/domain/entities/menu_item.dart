import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// Domain entity for a single menu item.
///
/// The mapper defaults `available` and `vegetarian` to `false` when the
/// DTO carries null (design decision: nullable backend booleans default
/// safely to false).
@immutable
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.available = false,
    this.vegetarian = false,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final Decimal price;
  final bool available;
  final bool vegetarian;
  final String? imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MenuItem(id: $id, name: $name, price: $price, available: $available)';
}
