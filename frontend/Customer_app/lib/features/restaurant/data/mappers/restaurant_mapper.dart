import 'package:flutter/material.dart';

import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';
import '../dtos/category_dto.dart';
import '../dtos/menu_item_dto.dart';
import '../dtos/restaurant_dto.dart';

/// Maps [RestaurantDto] → [Restaurant] domain entity.
///
/// Parses raw temporal strings to `TimeOfDay` / `DateTime` and defaults
/// nullable collections to empty lists.
class RestaurantMapper {
  const RestaurantMapper._();

  /// Converts a [RestaurantDto] to a [Restaurant] domain entity.
  static Restaurant fromDto(RestaurantDto dto) {
    return Restaurant(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      address: dto.address,
      city: dto.city,
      isOpen: dto.open,
      averageDeliveryTime: dto.averageDeliveryTime,
      rating: dto.rating,
      imageUrl: dto.imageUrl,
      logoUrl: dto.logoUrl,
      coverImageUrl: dto.coverImageUrl,
      cuisine: dto.cuisine,
      latitude: dto.latitude,
      longitude: dto.longitude,
      active: dto.active,
      openingTime: _parseTimeOfDay(dto.openingTime),
      closingTime: _parseTimeOfDay(dto.closingTime),
      createdAt: _parseDateTime(dto.createdAt),
      updatedAt: _parseDateTime(dto.updatedAt),
      categories: (dto.categories ?? [])
          .map(CategoryMapper.fromDto)
          .toList(growable: false),
    );
  }

  /// Parses a time string like "09:00" or "09:00:00" to [TimeOfDay].
  /// Returns `null` on parse failure or null input.
  static TimeOfDay? _parseTimeOfDay(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parts = raw.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {
      // Parsing failure — return null silently.
    }
    return null;
  }

  /// Parses a datetime string to [DateTime].
  /// Handles ISO 8601 and common Jackson formats.
  /// Returns `null` on parse failure or null input.
  static DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

/// Maps [CategoryDto] → [MenuCategory] domain entity.
class CategoryMapper {
  const CategoryMapper._();

  static MenuCategory fromDto(CategoryDto dto) {
    return MenuCategory(
      id: dto.id,
      name: dto.name,
      items: (dto.items ?? [])
          .map(MenuItemMapper.fromDto)
          .toList(growable: false),
    );
  }
}

/// Maps [MenuItemDto] → [MenuItem] domain entity.
///
/// Defaults `available` and `vegetarian` to `false` when the DTO carries null.
class MenuItemMapper {
  const MenuItemMapper._();

  static MenuItem fromDto(MenuItemDto dto) {
    return MenuItem(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      price: dto.price,
      available: dto.available ?? false,
      vegetarian: dto.vegetarian ?? false,
      imageUrl: dto.imageUrl,
    );
  }
}
