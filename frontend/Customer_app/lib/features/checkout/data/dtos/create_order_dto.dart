import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../orders/data/dtos/delivery_location_dto.dart';
import 'create_order_item_dto.dart';

part 'create_order_dto.freezed.dart';
part 'create_order_dto.g.dart';

/// Wire mirror of the order-service `CreateOrderRequest` — the `POST /orders`
/// request body (Req 13, 15).
///
/// Request-only and deliberately carries **no customer identifier**: the
/// backend derives the customer from the authenticated JWT, and the client must
/// never send one (Property 15). `restaurantId` is the string the backend
/// parses to a UUID. Reuses [DeliveryLocationDto] from the orders feature since
/// both directions share the same wire shape.
@freezed
abstract class CreateOrderDto with _$CreateOrderDto {
  @JsonSerializable(explicitToJson: true)
  const factory CreateOrderDto({
    required String restaurantId,
    required DeliveryLocationDto deliveryLocation,
    required String deliveryAddress,
    required List<CreateOrderItemDto> items,
  }) = _CreateOrderDto;

  /// Decodes a [CreateOrderDto] from a JSON map.
  factory CreateOrderDto.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderDtoFromJson(json);
}
