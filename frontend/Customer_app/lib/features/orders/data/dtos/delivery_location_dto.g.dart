// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliveryLocationDto _$DeliveryLocationDtoFromJson(Map<String, dynamic> json) =>
    _DeliveryLocationDto(
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$DeliveryLocationDtoToJson(
  _DeliveryLocationDto instance,
) => <String, dynamic>{
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
