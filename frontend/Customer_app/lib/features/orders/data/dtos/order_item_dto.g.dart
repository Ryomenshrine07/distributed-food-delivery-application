// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderItemDto _$OrderItemDtoFromJson(Map<String, dynamic> json) =>
    _OrderItemDto(
      id: json['id'] as String,
      menuItemId: json['menuItemId'] as String,
      itemName: json['itemName'] as String,
      price: const DecimalJsonConverter().fromJson(json['price']),
      quantity: (json['quantity'] as num).toInt(),
      totalPrice: const DecimalJsonConverter().fromJson(json['totalPrice']),
    );

Map<String, dynamic> _$OrderItemDtoToJson(_OrderItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menuItemId': instance.menuItemId,
      'itemName': instance.itemName,
      'price': const DecimalJsonConverter().toJson(instance.price),
      'quantity': instance.quantity,
      'totalPrice': const DecimalJsonConverter().toJson(instance.totalPrice),
    };
