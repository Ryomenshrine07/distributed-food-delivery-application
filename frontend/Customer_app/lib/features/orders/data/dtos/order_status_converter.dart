import 'package:json_annotation/json_annotation.dart';

import '../../domain/order_status.dart';

/// Tolerant JSON converter between the backend `OrderStatus` wire strings and
/// the [OrderStatus] enum.
///
/// Decoding routes any value that is not one of the nine recognized statuses
/// (including a non-string payload) to [OrderStatus.unknown] instead of
/// throwing, so a backend that introduces a new status cannot crash order
/// decoding. Encoding maps each enum value back to its canonical wire string;
/// the [OrderStatus.unknown] sentinel encodes to `"UNKNOWN"` so the value still
/// round-trips.
///
/// Apply to a freezed field with `@OrderStatusConverter()`.
class OrderStatusConverter implements JsonConverter<OrderStatus, Object?> {
  /// Creates a const converter instance for annotation use.
  const OrderStatusConverter();

  @override
  OrderStatus fromJson(Object? json) {
    if (json is! String) return OrderStatus.unknown;
    return switch (json) {
      'PENDING_PAYMENT' => OrderStatus.pendingPayment,
      'CONFIRMED' => OrderStatus.confirmed,
      'PREPARING' => OrderStatus.preparing,
      'READY_FOR_PICKUP' => OrderStatus.readyForPickup,
      'DELIVERY_PARTNER_ASSIGNED' => OrderStatus.deliveryPartnerAssigned,
      'OUT_FOR_DELIVERY' => OrderStatus.outForDelivery,
      'DELIVERED' => OrderStatus.delivered,
      'CANCELLED' => OrderStatus.cancelled,
      'FAILED' => OrderStatus.failed,
      _ => OrderStatus.unknown,
    };
  }

  @override
  Object? toJson(OrderStatus object) => switch (object) {
        OrderStatus.pendingPayment => 'PENDING_PAYMENT',
        OrderStatus.confirmed => 'CONFIRMED',
        OrderStatus.preparing => 'PREPARING',
        OrderStatus.readyForPickup => 'READY_FOR_PICKUP',
        OrderStatus.deliveryPartnerAssigned => 'DELIVERY_PARTNER_ASSIGNED',
        OrderStatus.outForDelivery => 'OUT_FOR_DELIVERY',
        OrderStatus.delivered => 'DELIVERED',
        OrderStatus.cancelled => 'CANCELLED',
        OrderStatus.failed => 'FAILED',
        OrderStatus.unknown => 'UNKNOWN',
      };
}
