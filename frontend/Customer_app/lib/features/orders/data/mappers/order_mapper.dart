import '../../domain/entities/delivery_location.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../dtos/delivery_location_dto.dart';
import '../dtos/order_dto.dart';
import '../dtos/order_item_dto.dart';

/// Maps [OrderDto] → [Order] domain entity.
///
/// Parses the raw `createdAt` string into a `DateTime`.
class OrderMapper {
  const OrderMapper._();

  static Order fromDto(OrderDto dto) {
    return Order(
      id: dto.id,
      customerId: dto.customerId,
      customerName: dto.customerName,
      customerPhone: dto.customerPhone,
      customerEmail: dto.customerEmail,
      deliveryPartnerId: dto.deliveryPartnerId,
      deliveryPartnerName: dto.deliveryPartnerName,
      deliveryPartnerPhone: dto.deliveryPartnerPhone,
      restaurantId: dto.restaurantId,
      deliveryLocation: DeliveryLocationMapper.fromDto(dto.deliveryLocation),
      subtotal: dto.subtotal,
      deliveryFee: dto.deliveryFee,
      tax: dto.tax,
      totalAmount: dto.totalAmount,
      status: dto.status,
      items: dto.items
          .map(OrderItemMapper.fromDto)
          .toList(growable: false),
      createdAt: _parseCreatedAt(dto.createdAt),
    );
  }

  /// Parses the order `createdAt` timestamp.
  /// Falls back to current time if parsing fails (defensive).
  static DateTime _parseCreatedAt(String raw) {
    return DateTime.tryParse(raw) ?? DateTime.now();
  }
}

/// Maps [OrderItemDto] → [OrderItem] domain entity.
class OrderItemMapper {
  const OrderItemMapper._();

  static OrderItem fromDto(OrderItemDto dto) {
    return OrderItem(
      id: dto.id,
      menuItemId: dto.menuItemId,
      itemName: dto.itemName,
      price: dto.price,
      quantity: dto.quantity,
      totalPrice: dto.totalPrice,
    );
  }
}

/// Maps [DeliveryLocationDto] → [DeliveryLocation] domain entity.
class DeliveryLocationMapper {
  const DeliveryLocationMapper._();

  static DeliveryLocation fromDto(DeliveryLocationDto dto) {
    return DeliveryLocation(
      address: dto.address,
      latitude: dto.latitude,
      longitude: dto.longitude,
    );
  }
}
