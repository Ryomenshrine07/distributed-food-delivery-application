import 'pending_confirmation.dart';

abstract class OfflineQueue {
  Future<void> enqueue(PendingConfirmation confirmation);
  Future<List<PendingConfirmation>> getQueue();
  Future<void> remove(String id);
  Future<void> update(PendingConfirmation confirmation);
  Future<void> clear();
}
