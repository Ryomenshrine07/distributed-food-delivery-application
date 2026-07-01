// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderDto _$OrderDtoFromJson(Map<String, dynamic> json) => _OrderDto(
  id: json['id'] as String,
  customerId: json['customerId'] as String?,
  customerName: json['customerName'] as String?,
  customerPhone: json['customerPhone'] as String?,
  customerEmail: json['customerEmail'] as String?,
  deliveryPartnerId: json['deliveryPartnerId'] as String?,
  deliveryPartnerName: json['deliveryPartnerName'] as String?,
  deliveryPartnerPhone: json['deliveryPartnerPhone'] as String?,
  restaurantId: json['restaurantId'] as String,
  deliveryLocation: DeliveryLocationDto.fromJson(
    json['deliveryLocation'] as Map<String, dynamic>,
  ),
  subtotal: const DecimalJsonConverter().fromJson(json['subtotal']),
  deliveryFee: const DecimalJsonConverter().fromJson(json['deliveryFee']),
  tax: const DecimalJsonConverter().fromJson(json['tax']),
  totalAmount: const DecimalJsonConverter().fromJson(json['totalAmount']),
  status: const OrderStatusConverter().fromJson(json['status']),
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$OrderDtoToJson(_OrderDto instance) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'customerPhone': instance.customerPhone,
  'customerEmail': instance.customerEmail,
  'deliveryPartnerId': instance.deliveryPartnerId,
  'deliveryPartnerName': instance.deliveryPartnerName,
  'deliveryPartnerPhone': instance.deliveryPartnerPhone,
  'restaurantId': instance.restaurantId,
  'deliveryLocation': instance.deliveryLocation,
  'subtotal': const DecimalJsonConverter().toJson(instance.subtotal),
  'deliveryFee': const DecimalJsonConverter().toJson(instance.deliveryFee),
  'tax': const DecimalJsonConverter().toJson(instance.tax),
  'totalAmount': const DecimalJsonConverter().toJson(instance.totalAmount),
  'status': const OrderStatusConverter().toJson(instance.status),
  'items': instance.items,
  'createdAt': instance.createdAt,
};
