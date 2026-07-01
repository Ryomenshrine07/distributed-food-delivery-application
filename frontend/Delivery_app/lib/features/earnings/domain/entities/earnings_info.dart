import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../history/domain/entities/delivery_record.dart';

part 'earnings_info.freezed.dart';
@freezed
abstract class EarningsInfo with _$EarningsInfo {
  const factory EarningsInfo({
    required double totalEarnings,
    required double todayEarnings,
    required double weekEarnings,
    required int totalDeliveries,
    required int todayDeliveries,
    required List<DeliveryRecord> recentRecords,
  }) = _EarningsInfo;
}
