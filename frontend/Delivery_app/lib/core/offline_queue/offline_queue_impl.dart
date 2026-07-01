import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'offline_queue.dart';
import 'pending_confirmation.dart';

class OfflineQueueImpl implements OfflineQueue {
  static const String _queueKey = 'offline_confirmation_queue';
  final SharedPreferences _prefs;

  OfflineQueueImpl(this._prefs);

  @override
  Future<void> enqueue(PendingConfirmation confirmation) async {
    final queue = await getQueue();
    queue.add(confirmation);
    await _saveQueue(queue);
  }

  @override
  Future<List<PendingConfirmation>> getQueue() async {
    final queueJson = _prefs.getStringList(_queueKey);
    if (queueJson == null) return [];
    return queueJson
        .map((jsonStr) => PendingConfirmation.fromJson(jsonDecode(jsonStr)))
        .toList()
      ..sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));
  }

  @override
  Future<void> remove(String id) async {
    final queue = await getQueue();
    queue.removeWhere((c) => c.id == id);
    await _saveQueue(queue);
  }

  @override
  Future<void> update(PendingConfirmation confirmation) async {
    final queue = await getQueue();
    final index = queue.indexWhere((c) => c.id == confirmation.id);
    if (index != -1) {
      queue[index] = confirmation;
      await _saveQueue(queue);
    }
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_queueKey);
  }

  Future<void> _saveQueue(List<PendingConfirmation> queue) async {
    final queueJson = queue.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_queueKey, queueJson);
  }
}
