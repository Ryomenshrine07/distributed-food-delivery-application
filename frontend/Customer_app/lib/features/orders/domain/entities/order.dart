import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../order_status.dart';
import 'delivery_location.dart';
import 'order_item.dart';

/// Domain entity for a customer order.
///
/// `createdAt` is parsed from the raw DTO string into a `DateTime`.
/// Customer identity fields are nullable — they come from the server response
/// but are not sent by the client (Property 15).
@immutable
class Order {
  const Order({
    required this.id,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.deliveryPartnerId,
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    required this.restaurantId,
    required this.deliveryLocation,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.totalAmount,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  final String id;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? deliveryPartnerId;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String restaurantId;
  final DeliveryLocation deliveryLocation;
  final Decimal subtotal;
  final Decimal deliveryFee;
  final Decimal tax;
  final Decimal totalAmount;
  final OrderStatus status;
  final List<OrderItem> items;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Order(id: $id, status: $status, total: $totalAmount)';
}
