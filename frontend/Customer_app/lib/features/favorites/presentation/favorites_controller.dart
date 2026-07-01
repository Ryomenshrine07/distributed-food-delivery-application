import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/preferences.dart';
import '../../restaurant/data/dtos/restaurant_dto.dart';
import '../../restaurant/data/mappers/restaurant_mapper.dart';
import '../../restaurant/domain/entities/restaurant.dart';

part 'favorites_controller.g.dart';

const _kFavoritesKey = 'customer_favorite_restaurants';

/// Controller for managing favorite restaurants using SharedPreferences.
@riverpod
class FavoritesController extends _$FavoritesController {
  @override
  List<Restaurant> build() {
    return _loadFavorites();
  }

  List<Restaurant> _loadFavorites() {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_kFavoritesKey);
    if (jsonStr == null) return [];
    
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) {
        final dto = RestaurantDto.fromJson(e as Map<String, dynamic>);
        return RestaurantMapper.fromDto(dto);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  bool isFavorite(String restaurantId) {
    return state.any((r) => r.id == restaurantId);
  }

  Future<void> toggleFavorite(Restaurant restaurant) async {
    final isFav = isFavorite(restaurant.id);
    List<Restaurant> updated;
    
    if (isFav) {
      updated = state.where((r) => r.id != restaurant.id).toList();
    } else {
      updated = [...state, restaurant];
    }
    
    await _persist(updated);
  }

  Future<void> _persist(List<Restaurant> favorites) async {
    final prefs = ref.read(sharedPreferencesProvider);
    // Since we don't have a toDto mapper, we'll manually map to the expected JSON format for DTO
    final jsonList = favorites.map((r) => {
      'id': r.id,
      'name': r.name,
      'description': r.description,
      'imageUrl': r.imageUrl,
      'rating': r.rating,
      'averageDeliveryTime': r.averageDeliveryTime,
      'cuisine': r.cuisine,
      'isOpen': r.isOpen,
    }).toList();
    
    await prefs.setString(_kFavoritesKey, jsonEncode(jsonList));
    state = favorites;
  }
}
