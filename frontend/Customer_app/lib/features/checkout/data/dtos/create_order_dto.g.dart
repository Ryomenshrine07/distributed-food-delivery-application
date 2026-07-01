// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateOrderDto _$CreateOrderDtoFromJson(Map<String, dynamic> json) =>
    _CreateOrderDto(
      restaurantId: json['restaurantId'] as String,
      deliveryLocation: DeliveryLocationDto.fromJson(
        json['deliveryLocation'] as Map<String, dynamic>,
      ),
      deliveryAddress: json['deliveryAddress'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CreateOrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateOrderDtoToJson(_CreateOrderDto instance) =>
    <String, dynamic>{
      'restaurantId': instance.restaurantId,
      'deliveryLocation': instance.deliveryLocation.toJson(),
      'deliveryAddress': instance.deliveryAddress,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
