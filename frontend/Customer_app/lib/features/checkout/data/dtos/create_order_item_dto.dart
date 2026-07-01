import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_order_item_dto.freezed.dart';
part 'create_order_item_dto.g.dart';

/// Wire mirror of the order-service `CreateOrderItemRequest` — one line of the
/// `POST /orders` request body (Req 13, 15).
///
/// Request-only. `quantity` is at least 1 (enforced upstream by the cart and
/// by the backend `@Min(1)` constraint). `menuItemId` is the string the
/// backend parses to a UUID.
@freezed
abstract class CreateOrderItemDto with _$CreateOrderItemDto {
  /// Creates a [CreateOrderItemDto].
  const factory CreateOrderItemDto({
    required String menuItemId,
    required String itemName,
    required int quantity,
  }) = _CreateOrderItemDto;

  /// Decodes a [CreateOrderItemDto] from a JSON map.
  factory CreateOrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderItemDtoFromJson(json);
}
