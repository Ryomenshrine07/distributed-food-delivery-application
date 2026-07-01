// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateOrderItemDto _$CreateOrderItemDtoFromJson(Map<String, dynamic> json) =>
    _CreateOrderItemDto(
      menuItemId: json['menuItemId'] as String,
      itemName: json['itemName'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$CreateOrderItemDtoToJson(_CreateOrderItemDto instance) =>
    <String, dynamic>{
      'menuItemId': instance.menuItemId,
      'itemName': instance.itemName,
      'quantity': instance.quantity,
    };
