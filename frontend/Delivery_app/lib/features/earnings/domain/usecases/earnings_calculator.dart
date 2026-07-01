import 'package:delivery_app/features/earnings/domain/entities/earnings_info.dart';
import 'package:delivery_app/features/history/domain/entities/delivery_record.dart';

class EarningsCalculator {
  /// Calculates aggregated earnings info from a list of delivery records.
  /// Records should ideally be sorted descending by time.
  static EarningsInfo calculate(List<DeliveryRecord> records, {DateTime? now}) {
    final referenceDate = now ?? DateTime.now();
    
    double totalEarnings = 0;
    double todayEarnings = 0;
    double weekEarnings = 0;
    int totalDeliveries = records.length;
    int todayDeliveries = 0;

    final startOfToday = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    // Determine the start of the week (assuming Monday is the first day of the week)
    final daysSinceMonday = referenceDate.weekday - 1;
    final startOfWeek = startOfToday.subtract(Duration(days: daysSinceMonday));

    for (final record in records) {
      final payout = record.payout;
      totalEarnings += payout;

      final deliveredAt = record.deliveredAt;
      
      if (!deliveredAt.isBefore(startOfToday)) {
        todayEarnings += payout;
        todayDeliveries++;
      }

      if (!deliveredAt.isBefore(startOfWeek)) {
        weekEarnings += payout;
      }
    }

    // Recent records: just take up to top 10 (assuming they're already sorted)
    final recentRecords = records.take(10).toList();

    return EarningsInfo(
      totalEarnings: totalEarnings,
      todayEarnings: todayEarnings,
      weekEarnings: weekEarnings,
      totalDeliveries: totalDeliveries,
      todayDeliveries: todayDeliveries,
      recentRecords: recentRecords,
    );
  }
}
