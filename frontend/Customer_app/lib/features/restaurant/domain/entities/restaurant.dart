import 'package:flutter/material.dart';

import 'menu_category.dart';

/// Domain entity for a restaurant.
///
/// Temporal fields are parsed from the raw DTO strings into `TimeOfDay` and
/// `DateTime`; nullable defaults are applied by the mapper.
@immutable
class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.isOpen,
    this.averageDeliveryTime,
    this.rating,
    this.imageUrl,
    this.logoUrl,
    this.coverImageUrl,
    this.cuisine,
    this.latitude,
    this.longitude,
    required this.active,
    this.openingTime,
    this.closingTime,
    this.createdAt,
    this.updatedAt,
    this.categories = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final bool? isOpen;
  final int? averageDeliveryTime;
  final double? rating;
  final String? imageUrl;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? cuisine;
  final double? latitude;
  final double? longitude;
  final bool active;
  final TimeOfDay? openingTime;
  final TimeOfDay? closingTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<MenuCategory> categories;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Restaurant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Restaurant(id: $id, name: $name, rating: $rating, open: $isOpen)';
}
