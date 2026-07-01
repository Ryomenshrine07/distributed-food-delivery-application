import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../history/presentation/providers/history_providers.dart';
import '../../domain/entities/earnings_info.dart';

part 'earnings_providers.g.dart';

@riverpod
class EarningsController extends _$EarningsController {
  @override
  Future<EarningsInfo> build() async {
    // In a real app, this would fetch from an API.
    // For now, we compute from the local history DB.
    final historyDs = ref.watch(historyDataSourceProvider);
    final allRecords = await historyDs.getAllRecords();

    double total = 0;
    double today = 0;
    double week = 0;
    int totalDel = allRecords.length;
    int todayDel = 0;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));

    for (final record in allRecords) {
      total += record.payout;
      
      if (record.deliveredAt.isAfter(startOfDay)) {
        today += record.payout;
        todayDel++;
      }
      
      if (record.deliveredAt.isAfter(startOfWeek)) {
        week += record.payout;
      }
    }

    final recent = allRecords.take(5).toList();

    return EarningsInfo(
      totalEarnings: total,
      todayEarnings: today,
      weekEarnings: week,
      totalDeliveries: totalDel,
      todayDeliveries: todayDel,
      recentRecords: recent,
    );
  }
}
