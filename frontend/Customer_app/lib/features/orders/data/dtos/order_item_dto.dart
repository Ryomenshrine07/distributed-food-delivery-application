import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/decimal_converter.dart';

part 'order_item_dto.freezed.dart';
part 'order_item_dto.g.dart';

/// Wire mirror of the order-service `OrderItemResponse` (Req 16, 17).
///
/// `price` and `totalPrice` are monetary and decoded via [DecimalJsonConverter]
/// for exactness; `id` and `menuItemId` are backend UUIDs serialized as
/// strings.
@freezed
abstract class OrderItemDto with _$OrderItemDto {
  /// Creates an [OrderItemDto].
  const factory OrderItemDto({
    required String id,
    required String menuItemId,
    required String itemName,
    @DecimalJsonConverter() required Decimal price,
    required int quantity,
    @DecimalJsonConverter() required Decimal totalPrice,
  }) = _OrderItemDto;

  /// Decodes an [OrderItemDto] from a JSON map.
  factory OrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderItemDtoFromJson(json);
}
