// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_confirmation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PendingConfirmation _$PendingConfirmationFromJson(Map<String, dynamic> json) =>
    _PendingConfirmation(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      type: $enumDecode(_$ConfirmationTypeEnumMap, json['type']),
      enqueuedAt: DateTime.parse(json['enqueuedAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PendingConfirmationToJson(
  _PendingConfirmation instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'type': _$ConfirmationTypeEnumMap[instance.type]!,
  'enqueuedAt': instance.enqueuedAt.toIso8601String(),
  'retryCount': instance.retryCount,
};

const _$ConfirmationTypeEnumMap = {ConfirmationType.pickedUp: 'pickedUp'};
