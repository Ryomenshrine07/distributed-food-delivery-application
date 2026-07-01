import 'package:delivery_app/features/earnings/domain/usecases/earnings_calculator.dart';
import 'package:delivery_app/features/history/domain/entities/delivery_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EarningsCalculator', () {
    final now = DateTime(2023, 10, 25, 14, 0); // Wednesday, Oct 25, 2023

    DeliveryRecord createRecord(String id, DateTime time, double payout) {
      return DeliveryRecord(
        orderId: id,
        deliveredAt: time,
        pickupAddress: 'P',
        dropAddress: 'D',
        distanceKm: 2.0,
        payout: payout,
      );
    }

    test('calculates empty records correctly', () {
      final info = EarningsCalculator.calculate([], now: now);

      expect(info.totalEarnings, 0);
      expect(info.todayEarnings, 0);
      expect(info.weekEarnings, 0);
      expect(info.totalDeliveries, 0);
      expect(info.todayDeliveries, 0);
      expect(info.recentRecords, isEmpty);
    });

    test('calculates earnings across different periods', () {
      final records = [
        // Today
        createRecord('1', DateTime(2023, 10, 25, 10, 0), 10.0),
        createRecord('2', DateTime(2023, 10, 25, 11, 0), 15.0),
        
        // Yesterday (Still this week, since Monday is Oct 23)
        createRecord('3', DateTime(2023, 10, 24, 10, 0), 12.0),
        createRecord('4', DateTime(2023, 10, 23, 10, 0), 8.0), // Monday

        // Last week (Sunday)
        createRecord('5', DateTime(2023, 10, 22, 10, 0), 20.0),
      ];

      final info = EarningsCalculator.calculate(records, now: now);

      // Today: 10 + 15 = 25
      expect(info.todayEarnings, 25.0);
      expect(info.todayDeliveries, 2);

      // This week: 10 + 15 + 12 + 8 = 45
      expect(info.weekEarnings, 45.0);

      // Total: 45 + 20 = 65
      expect(info.totalEarnings, 65.0);
      expect(info.totalDeliveries, 5);
      
      expect(info.recentRecords.length, 5);
    });

    test('limits recent records to 10', () {
      final records = List.generate(
        15,
        (i) => createRecord('$i', now.subtract(Duration(days: i)), 10.0),
      );

      final info = EarningsCalculator.calculate(records, now: now);

      expect(info.recentRecords.length, 10);
      expect(info.totalDeliveries, 15);
      expect(info.totalEarnings, 150.0);
    });
  });
}
