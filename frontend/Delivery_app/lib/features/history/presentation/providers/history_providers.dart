import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/history_local_data_source.dart';
import '../../domain/entities/delivery_record.dart';

part 'history_providers.g.dart';

final historyDataSourceProvider = Provider<HistoryLocalDataSource>((ref) {
  return HistoryLocalDataSource();
});

@riverpod
class HistoryController extends _$HistoryController {
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  Future<List<DeliveryRecord>> build() async {
    _currentPage = 0;
    _hasMore = true;
    final ds = ref.watch(historyDataSourceProvider);
    final records = await ds.getRecords(page: 0, pageSize: _pageSize);
    _hasMore = records.length == _pageSize;
    return records;
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    _currentPage++;
    final ds = ref.read(historyDataSourceProvider);
    final moreRecords = await ds.getRecords(page: _currentPage, pageSize: _pageSize);
    _hasMore = moreRecords.length == _pageSize;
    final current = state.value ?? [];
    state = AsyncValue.data([...current, ...moreRecords]);
  }
}
