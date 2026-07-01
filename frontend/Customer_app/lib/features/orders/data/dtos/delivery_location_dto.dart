import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_location_dto.freezed.dart';
part 'delivery_location_dto.g.dart';

/// Wire mirror of the order-service `DeliveryLocationRequest` /
/// `DeliveryLocationResponse` (Req 13, 15).
///
/// A single DTO serves both directions: it is embedded in [OrderDto] on
/// responses and built into the `POST /orders` request body. `latitude` and
/// `longitude` are non-null doubles (the request requires them).
@freezed
abstract class DeliveryLocationDto with _$DeliveryLocationDto {
  /// Creates a [DeliveryLocationDto].
  const factory DeliveryLocationDto({
    required String address,
    required double latitude,
    required double longitude,
  }) = _DeliveryLocationDto;

  /// Decodes a [DeliveryLocationDto] from a JSON map.
  factory DeliveryLocationDto.fromJson(Map<String, dynamic> json) =>
      _$DeliveryLocationDtoFromJson(json);
}
