// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiResponseDto<T> _$ApiResponseDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _ApiResponseDto<T>(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: fromJsonT(json['data']),
);

Map<String, dynamic> _$ApiResponseDtoToJson<T>(
  _ApiResponseDto<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': toJsonT(instance.data),
};
