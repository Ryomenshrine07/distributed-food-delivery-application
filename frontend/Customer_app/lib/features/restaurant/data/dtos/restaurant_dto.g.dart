// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RestaurantDto _$RestaurantDtoFromJson(Map<String, dynamic> json) =>
    _RestaurantDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      open: json['open'] as bool?,
      averageDeliveryTime: (json['averageDeliveryTime'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      cuisine: json['cuisine'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      active: json['active'] as bool,
      openingTime: json['openingTime'] as String?,
      closingTime: json['closingTime'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RestaurantDtoToJson(_RestaurantDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'city': instance.city,
      'open': instance.open,
      'averageDeliveryTime': instance.averageDeliveryTime,
      'rating': instance.rating,
      'imageUrl': instance.imageUrl,
      'logoUrl': instance.logoUrl,
      'coverImageUrl': instance.coverImageUrl,
      'cuisine': instance.cuisine,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'active': instance.active,
      'openingTime': instance.openingTime,
      'closingTime': instance.closingTime,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'categories': instance.categories,
    };
