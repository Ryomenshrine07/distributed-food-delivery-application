// Verifies the rider self-completion code path has been fully removed and the
// picked-up state offers no self-complete action (Item 3, Req 3.6, 3.7).
//
//  - Static guard: no lib/ source references `markDelivered`, `confirmDelivery`
//    or the `/delivered` endpoint remain anywhere (including generated code).
//  - Widget: the picked-up assignment detail renders a non-actionable
//    "Waiting for customer confirmation" state, keeps "Navigate to Customer",
//    and shows no "Confirm Delivery" control.

import 'dart:io';

import 'package:delivery_app/features/assignment/domain/entities/delivery_assignment.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_status.dart';
import 'package:delivery_app/features/assignment/domain/repositories/assignment_repository.dart';
import 'package:delivery_app/features/assignment/presentation/providers/assignment_providers.dart';
import 'package:delivery_app/features/assignment/presentation/screens/assignment_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAssignmentRepository extends Mock implements AssignmentRepository {}

void main() {
  group('rider self-completion removal (static guard)', () {
    // Symbols that must no longer appear anywhere in the app source. Each maps
    // to a piece of the removed rider self-complete path.
    const forbidden = <String>[
      'markDelivered', // repository operation
      'confirmDelivery', // controller method + use case + provider
      '/delivered', // the delivery-service self-complete endpoint call
    ];

    test('no lib/ dart source references any self-completion symbol', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue,
          reason: 'test must run from the Delivery_app package root');

      final offenders = <String>[];
      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final contents = entity.readAsStringSync();
        for (final symbol in forbidden) {
          if (contents.contains(symbol)) {
            offenders.add('${entity.path} contains "$symbol"');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'rider self-completion code path must be fully removed:\n'
            '${offenders.join('\n')}',
      );
    });
  });

  group('picked-up assignment detail', () {
    late MockAssignmentRepository repo;

    setUp(() {
      repo = MockAssignmentRepository();
    });

    DeliveryAssignment pickedUp() => const DeliveryAssignment(
          id: 'assign_1',
          orderId: 'order_1',
          restaurantName: 'Pizza Place',
          restaurantAddress: '1 Oven Street',
          restaurantLatitude: 1,
          restaurantLongitude: 2,
          customerName: 'Jane Customer',
          customerAddress: '2 Home Road',
          customerLatitude: 3,
          customerLongitude: 4,
          customerPhone: '+15551234567',
          itemCount: 2,
          status: DeliveryStatus.pickedUp,
        );

    testWidgets('renders the waiting state and no self-complete button',
        (tester) async {
      when(() => repo.getActiveAssignment())
          .thenAnswer((_) async => pickedUp());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assignmentRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: AssignmentDetailScreen(orderId: 'order_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The non-actionable waiting state replaces the old rider action.
      expect(find.text('Waiting for customer confirmation'), findsOneWidget);
      // The hand-off navigation action is preserved.
      expect(find.text('Navigate to Customer'), findsOneWidget);
      // No rider self-complete control remains.
      expect(find.text('Confirm Delivery'), findsNothing);
    });
  });
}
