import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_record.freezed.dart';
part 'delivery_record.g.dart';

@freezed
abstract class DeliveryRecord with _$DeliveryRecord {
  const factory DeliveryRecord({
    required String orderId,
    required DateTime deliveredAt,
    required String pickupAddress,
    required String dropAddress,
    required double distanceKm,
    required double payout,
  }) = _DeliveryRecord;

  factory DeliveryRecord.fromJson(Map<String, dynamic> json) =>
      _$DeliveryRecordFromJson(json);
}
