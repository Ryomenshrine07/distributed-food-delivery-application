import 'package:freezed_annotation/freezed_annotation.dart';

import 'category_dto.dart';

part 'restaurant_dto.freezed.dart';
part 'restaurant_dto.g.dart';

/// Wire mirror of the restaurant-service `RestaurantResponse` (Req 7, 9, 10).
///
/// Nullability follows the backend record exactly: `active` is the only
/// non-null boolean; `open`, `averageDeliveryTime`, `rating` and the textual
/// fields are optional. Temporal fields (`openingTime`/`closingTime` =
/// `LocalTime`; `createdAt`/`updatedAt` = `LocalDateTime`) are retained as raw
/// strings so serialization round-trips independently of the wire format; the
/// DTO→entity mapper (task 7.2) parses them to `TimeOfDay`/`DateTime`.
/// `categories` is null on the list endpoint and populated on the menu
/// endpoint; the mapper defaults a missing list to `[]`.
@freezed
abstract class RestaurantDto with _$RestaurantDto {
  /// Creates a [RestaurantDto].
  const factory RestaurantDto({
    required String id,
    required String name,
    String? description,
    String? address,
    String? city,
    bool? open,
    int? averageDeliveryTime,
    double? rating,
    String? imageUrl,
    String? logoUrl,
    String? coverImageUrl,
    String? cuisine,
    double? latitude,
    double? longitude,
    required bool active,
    String? openingTime,
    String? closingTime,
    String? createdAt,
    String? updatedAt,
    List<CategoryDto>? categories,
  }) = _RestaurantDto;

  /// Decodes a [RestaurantDto] from a JSON map.
  factory RestaurantDto.fromJson(Map<String, dynamic> json) =>
      _$RestaurantDtoFromJson(json);
}
