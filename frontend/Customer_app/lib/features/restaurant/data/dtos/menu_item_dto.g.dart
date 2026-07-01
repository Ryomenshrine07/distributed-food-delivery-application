// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuItemDto _$MenuItemDtoFromJson(Map<String, dynamic> json) => _MenuItemDto(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  price: const DecimalJsonConverter().fromJson(json['price']),
  available: json['available'] as bool?,
  vegetarian: json['vegetarian'] as bool?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$MenuItemDtoToJson(_MenuItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': const DecimalJsonConverter().toJson(instance.price),
      'available': instance.available,
      'vegetarian': instance.vegetarian,
      'imageUrl': instance.imageUrl,
    };
