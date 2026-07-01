// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationUpdateRequestDto _$LocationUpdateRequestDtoFromJson(
  Map<String, dynamic> json,
) => _LocationUpdateRequestDto(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$LocationUpdateRequestDtoToJson(
  _LocationUpdateRequestDto instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
