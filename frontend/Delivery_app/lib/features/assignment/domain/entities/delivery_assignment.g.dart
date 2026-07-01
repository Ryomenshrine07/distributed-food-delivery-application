// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliveryAssignment _$DeliveryAssignmentFromJson(Map<String, dynamic> json) =>
    _DeliveryAssignment(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      restaurantName: json['restaurantName'] as String? ?? 'Unknown Restaurant',
      restaurantAddress:
          json['restaurantAddress'] as String? ?? 'Unknown Address',
      restaurantLatitude: (json['restaurantLatitude'] as num).toDouble(),
      restaurantLongitude: (json['restaurantLongitude'] as num).toDouble(),
      customerName: json['customerName'] as String? ?? 'Unknown Customer',
      customerAddress: json['customerAddress'] as String? ?? 'Unknown Address',
      customerLatitude: (json['customerLatitude'] as num?)?.toDouble() ?? 0.0,
      customerLongitude: (json['customerLongitude'] as num?)?.toDouble() ?? 0.0,
      customerPhone: json['customerPhone'] as String?,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      status: $enumDecode(_$DeliveryStatusEnumMap, json['status']),
      assignedAt: json['assignedAt'] == null
          ? null
          : DateTime.parse(json['assignedAt'] as String),
      pickedUpAt: json['pickedUpAt'] == null
          ? null
          : DateTime.parse(json['pickedUpAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
    );

Map<String, dynamic> _$DeliveryAssignmentToJson(_DeliveryAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'restaurantName': instance.restaurantName,
      'restaurantAddress': instance.restaurantAddress,
      'restaurantLatitude': instance.restaurantLatitude,
      'restaurantLongitude': instance.restaurantLongitude,
      'customerName': instance.customerName,
      'customerAddress': instance.customerAddress,
      'customerLatitude': instance.customerLatitude,
      'customerLongitude': instance.customerLongitude,
      'customerPhone': instance.customerPhone,
      'itemCount': instance.itemCount,
      'status': _$DeliveryStatusEnumMap[instance.status]!,
      'assignedAt': instance.assignedAt?.toIso8601String(),
      'pickedUpAt': instance.pickedUpAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
    };

const _$DeliveryStatusEnumMap = {
  DeliveryStatus.pending: 'PENDING',
  DeliveryStatus.assigned: 'ASSIGNED',
  DeliveryStatus.pickedUp: 'PICKED_UP',
  DeliveryStatus.delivered: 'DELIVERED',
};
