// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliveryRecord _$DeliveryRecordFromJson(Map<String, dynamic> json) =>
    _DeliveryRecord(
      orderId: json['orderId'] as String,
      deliveredAt: DateTime.parse(json['deliveredAt'] as String),
      pickupAddress: json['pickupAddress'] as String,
      dropAddress: json['dropAddress'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      payout: (json['payout'] as num).toDouble(),
    );

Map<String, dynamic> _$DeliveryRecordToJson(_DeliveryRecord instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'deliveredAt': instance.deliveredAt.toIso8601String(),
      'pickupAddress': instance.pickupAddress,
      'dropAddress': instance.dropAddress,
      'distanceKm': instance.distanceKm,
      'payout': instance.payout,
    };
