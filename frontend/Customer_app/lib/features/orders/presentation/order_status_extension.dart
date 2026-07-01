import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';
import '../domain/order_status.dart';

extension OrderStatusColor on OrderStatus {
  Color color(AppTokens tokens) {
    return switch (this) {
      OrderStatus.pendingPayment => tokens.statusPendingPayment,
      OrderStatus.confirmed => tokens.statusConfirmed,
      OrderStatus.preparing => tokens.statusPreparing,
      OrderStatus.readyForPickup => tokens.statusReadyForPickup,
      OrderStatus.deliveryPartnerAssigned => tokens.statusDeliveryPartnerAssigned,
      OrderStatus.outForDelivery => tokens.statusOutForDelivery,
      OrderStatus.delivered => tokens.statusDelivered,
      OrderStatus.cancelled => tokens.statusCancelled,
      OrderStatus.failed => tokens.statusFailed,
      OrderStatus.unknown => tokens.statusPendingPayment,
    };
  }
}
