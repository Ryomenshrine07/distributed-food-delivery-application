import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../restaurant/data/dtos/restaurant_dto.dart';

/// Remote data source for restaurant-related endpoints.
///
/// Communicates with the restaurant service via ApiClient's envelope
/// methods (the restaurant service wraps responses in ApiResponse).
class RestaurantRemoteDataSource {
  RestaurantRemoteDataSource({required ApiClient apiClient})
      : _api = apiClient;

  final ApiClient _api;

  /// GET /restaurants — paginated restaurant list with optional filters.
  Future<dynamic> getRestaurants({
    int page = 0,
    int size = 10,
    String? city,
    String? category,
    CancelToken? cancelToken,
  }) {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      if (city != null && city.isNotEmpty) 'city': city,
      if (category != null && category.isNotEmpty) 'category': category,
    };

    return _api.getEnvelopePage<RestaurantDto>(
      '/restaurants',
      queryParams: query,
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          RestaurantDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// GET /restaurants/search — search by keyword with pagination.
  Future<dynamic> searchRestaurants({
    required String keyword,
    int page = 0,
    int size = 10,
    CancelToken? cancelToken,
  }) {
    return _api.getEnvelopePage<RestaurantDto>(
      '/restaurants/search',
      queryParams: {
        'keyword': keyword,
        'page': page,
        'size': size,
      },
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          RestaurantDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// GET /restaurants/{id} — single restaurant detail.
  Future<RestaurantDto> getRestaurantById(String id) {
    return _api.getEnvelope<RestaurantDto>(
      '/restaurants/$id',
      fromJsonT: (json) =>
          RestaurantDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// GET /restaurants/{restaurantId}/menu — restaurant with full menu.
  Future<RestaurantDto> getRestaurantMenu(String restaurantId) {
    return _api.getEnvelope<RestaurantDto>(
      '/restaurants/$restaurantId/menu',
      fromJsonT: (json) =>
          RestaurantDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
