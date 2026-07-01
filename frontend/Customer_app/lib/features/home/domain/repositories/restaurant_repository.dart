import '../../../../core/error/result.dart';
import '../../../../core/network/page_response.dart';
import '../../../restaurant/domain/entities/restaurant.dart';

/// Interface for restaurant data access.
///
/// Covers the restaurant listing, search, detail, and menu endpoints.
abstract interface class RestaurantRepository {
  /// Fetches a paginated list of restaurants with optional filters.
  ///
  /// GET /restaurants?page=&size=&city=&category=
  Future<Result<PageResult<Restaurant>>> getRestaurants({
    int page = 0,
    int size = 10,
    String? city,
    String? category,
  });

  /// Searches restaurants by keyword with pagination.
  ///
  /// GET /restaurants/search?keyword=&page=&size=
  Future<Result<PageResult<Restaurant>>> search({
    required String keyword,
    int page = 0,
    int size = 10,
  });

  /// Fetches a restaurant by its ID.
  ///
  /// GET /restaurants/{id}
  Future<Result<Restaurant>> getById(String id);

  /// Fetches a restaurant with its full menu (categories + items).
  ///
  /// GET /restaurants/{restaurantId}/menu
  Future<Result<Restaurant>> getMenu(String restaurantId);
}
