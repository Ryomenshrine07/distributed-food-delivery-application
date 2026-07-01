import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/decimal_converter.dart';
import '../../domain/order_status.dart';
import 'delivery_location_dto.dart';
import 'order_item_dto.dart';
import 'order_status_converter.dart';

part 'order_dto.freezed.dart';
part 'order_dto.g.dart';

/// Wire mirror of the order-service `OrderResponse` (Req 14, 16, 17).
///
/// Money fields (`subtotal`, `deliveryFee`, `tax`, `totalAmount`) are decoded
/// via [DecimalJsonConverter] for exactness. `status` uses the tolerant
/// [OrderStatusConverter], which routes any unrecognized value to
/// [OrderStatus.unknown] rather than throwing. `createdAt` (an `OffsetDateTime`
/// on the wire) is retained as a raw string so the round-trip is independent of
/// the wire format; the DTO→entity mapper (task 7.2) parses it to `DateTime`.
///
/// The customer identity fields echoed by the response are kept nullable: the
/// client does not require them, and the order request never sends a customer
/// identifier (Property 15).
@freezed
abstract class OrderDto with _$OrderDto {
  /// Creates an [OrderDto].
  const factory OrderDto({
    required String id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? deliveryPartnerId,
    String? deliveryPartnerName,
    String? deliveryPartnerPhone,
    required String restaurantId,
    required DeliveryLocationDto deliveryLocation,
    @DecimalJsonConverter() required Decimal subtotal,
    @DecimalJsonConverter() required Decimal deliveryFee,
    @DecimalJsonConverter() required Decimal tax,
    @DecimalJsonConverter() required Decimal totalAmount,
    @OrderStatusConverter() required OrderStatus status,
    required List<OrderItemDto> items,
    required String createdAt,
  }) = _OrderDto;

  /// Decodes an [OrderDto] from a JSON map.
  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);
}
