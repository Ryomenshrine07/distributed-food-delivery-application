import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app/core/offline_queue/offline_queue_impl.dart';
import 'package:delivery_app/core/offline_queue/pending_confirmation.dart';

// Feature: delivery-app, Property P-9
void main() {
  late OfflineQueueImpl queue;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    queue = OfflineQueueImpl(prefs);
  });

  test('offline queue returns items sorted by enqueuedAt (FIFO by time)', () async {
    final random = Random(42);

    // Run 100 iterations of property-based checks
    for (var iteration = 0; iteration < 100; iteration++) {
      await queue.clear();

      final count = random.nextInt(10) + 1;
      final confirmations = List.generate(count, (i) {
        return PendingConfirmation(
          id: 'id_${iteration}_$i',
          orderId: 'order_${iteration}_$i',
          type: random.nextBool() ? ConfirmationType.pickedUp : ConfirmationType.delivered,
          enqueuedAt: DateTime(2024, 1, 1).add(Duration(
            seconds: random.nextInt(365 * 24 * 3600),
          )),
        );
      });

      // Enqueue in random order
      final shuffled = List<PendingConfirmation>.from(confirmations)..shuffle(random);
      for (final c in shuffled) {
        await queue.enqueue(c);
      }

      // Retrieve
      final retrieved = await queue.getQueue();

      // Must be sorted by enqueuedAt ascending (FIFO by time)
      expect(retrieved.length, count);
      for (var i = 1; i < retrieved.length; i++) {
        expect(
          retrieved[i].enqueuedAt.isAfter(retrieved[i - 1].enqueuedAt) ||
              retrieved[i].enqueuedAt.isAtSameMomentAs(retrieved[i - 1].enqueuedAt),
          isTrue,
          reason: 'Queue must maintain FIFO ordering by enqueuedAt at iteration $iteration, index $i',
        );
      }
    }
  });

  test('enqueue and remove maintains consistency', () async {
    final c1 = PendingConfirmation(
      id: 'c1', orderId: 'o1', type: ConfirmationType.pickedUp,
      enqueuedAt: DateTime(2024, 1, 1),
    );
    final c2 = PendingConfirmation(
      id: 'c2', orderId: 'o2', type: ConfirmationType.delivered,
      enqueuedAt: DateTime(2024, 1, 2),
    );
    final c3 = PendingConfirmation(
      id: 'c3', orderId: 'o3', type: ConfirmationType.pickedUp,
      enqueuedAt: DateTime(2024, 1, 3),
    );

    await queue.enqueue(c1);
    await queue.enqueue(c2);
    await queue.enqueue(c3);

    expect((await queue.getQueue()).length, 3);

    await queue.remove('c2');
    final afterRemove = await queue.getQueue();
    expect(afterRemove.length, 2);
    expect(afterRemove.map((c) => c.id).toList(), ['c1', 'c3']);
  });

  test('update modifies retry count correctly', () async {
    final c = PendingConfirmation(
      id: 'cu', orderId: 'ou', type: ConfirmationType.pickedUp,
      enqueuedAt: DateTime(2024, 1, 1),
    );
    await queue.enqueue(c);

    final updated = c.copyWith(retryCount: 3);
    await queue.update(updated);

    final retrieved = await queue.getQueue();
    expect(retrieved.first.retryCount, 3);
  });

  test('clear empties the queue', () async {
    for (var i = 0; i < 5; i++) {
      await queue.enqueue(PendingConfirmation(
        id: 'clr_$i', orderId: 'o_$i', type: ConfirmationType.delivered,
        enqueuedAt: DateTime(2024, 1, i + 1),
      ));
    }
    expect((await queue.getQueue()).length, 5);
    await queue.clear();
    expect((await queue.getQueue()).length, 0);
  });
}
