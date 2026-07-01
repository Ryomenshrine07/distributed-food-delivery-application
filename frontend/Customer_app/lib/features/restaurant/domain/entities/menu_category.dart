import 'package:flutter/foundation.dart';

import 'menu_item.dart';

/// Domain entity for a menu category within a restaurant.
///
/// Groups [items] by category name. The mapper defaults `items` to `[]` when
/// the backend returns null.
@immutable
class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.name,
    this.items = const [],
  });

  final String id;
  final String name;
  final List<MenuItem> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MenuCategory(id: $id, name: $name, items: ${items.length})';
}
