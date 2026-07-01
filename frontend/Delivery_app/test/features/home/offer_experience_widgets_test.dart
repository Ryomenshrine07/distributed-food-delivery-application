// Widget tests for the redesigned delivery offer / active-assignment
// experience (Item 7).
//
//  - OfferCard renders restaurant/customer/item info and actions   (Req 7.3)
//  - OfferCard inline progress + disabled actions while accepting  (Req 7.6)
//  - OfferCard Accept/Dismiss invoke their callbacks
//  - ActiveAssignmentCard renders the status timeline + next action(Req 7.11)
//  - Home offers animate in with a slide/fade entrance             (Req 7.4)
//  - Home Accept triggers the unchanged acceptOffer flow -> active (Req 7.5)
//  - Home session dismiss removes the offer card                   (Req 7.8)

import 'dart:async';

import 'package:delivery_app/core/error/result.dart';
import 'package:delivery_app/core/theme/app_theme.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_assignment.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_status.dart';
import 'package:delivery_app/features/assignment/domain/repositories/assignment_repository.dart';
import 'package:delivery_app/features/assignment/presentation/providers/assignment_providers.dart';
import 'package:delivery_app/features/assignment/presentation/widgets/active_assignment_card.dart';
import 'package:delivery_app/features/assignment/presentation/widgets/offer_card.dart';
import 'package:delivery_app/features/availability/domain/repositories/availability_repository.dart';
import 'package:delivery_app/features/availability/presentation/providers/availability_providers.dart';
import 'package:delivery_app/features/home/presentation/screens/home_screen.dart';
import 'package:delivery_app/features/location/domain/repositories/background_location_repository.dart';
import 'package:delivery_app/features/location/presentation/providers/location_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAssignmentRepository extends Mock implements AssignmentRepository {}

class MockAvailabilityRepository extends Mock implements AvailabilityRepository {}

class MockBackgroundLocationRepository extends Mock
    implements BackgroundLocationRepository {}

DeliveryAssignment _offer(
  String orderId, {
  int itemCount = 2,
  DeliveryStatus status = DeliveryStatus.pending,
}) =>
    DeliveryAssignment(
      id: 'assign-$orderId',
      orderId: orderId,
      restaurantName: 'Pizza Palace',
      restaurantAddress: '1 Oven Street',
      restaurantLatitude: 1,
      restaurantLongitude: 2,
      customerName: 'Jane Customer',
      customerAddress: '2 Home Road',
      customerLatitude: 3,
      customerLongitude: 4,
      itemCount: itemCount,
      status: status,
    );

Widget _themed(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_offer('fallback'));
  });

  group('OfferCard', () {
    testWidgets('renders restaurant, customer, and item info (Req 7.3)',
        (tester) async {
      await tester.pumpWidget(
        _themed(
          OfferCard(
            offer: _offer('o1', itemCount: 3),
            onAccept: () {},
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('Pizza Palace'), findsOneWidget);
      expect(find.text('1 Oven Street'), findsOneWidget);
      expect(find.text('Jane Customer'), findsOneWidget);
      expect(find.text('2 Home Road'), findsOneWidget);
      expect(find.text('3 items'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Accept'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Dismiss'), findsOneWidget);
    });

    testWidgets('shows inline progress and disables actions while accepting '
        '(Req 7.6)', (tester) async {
      await tester.pumpWidget(
        _themed(
          OfferCard(
            offer: _offer('o1'),
            onAccept: () {},
            onDismiss: () {},
            isAccepting: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
    });

    testWidgets('Accept and Dismiss invoke their callbacks', (tester) async {
      var accepted = 0;
      var dismissed = 0;
      await tester.pumpWidget(
        _themed(
          OfferCard(
            offer: _offer('o1'),
            onAccept: () => accepted++,
            onDismiss: () => dismissed++,
          ),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Accept'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Dismiss'));
      await tester.pump();

      expect(accepted, 1);
      expect(dismissed, 1);
    });

    testWidgets('action tap targets are at least 48px high (Req 9.1)',
        (tester) async {
      await tester.pumpWidget(
        _themed(
          OfferCard(offer: _offer('o1'), onAccept: () {}, onDismiss: () {}),
        ),
      );

      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.byType(OutlinedButton)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('ActiveAssignmentCard', () {
    testWidgets('renders the status timeline and next navigation action '
        '(Req 7.11)', (tester) async {
      var navigated = 0;
      await tester.pumpWidget(
        _themed(
          ActiveAssignmentCard(
            assignment: _offer('o1', status: DeliveryStatus.assigned),
            onNavigate: () => navigated++,
          ),
        ),
      );

      // Timeline steps.
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('Picked up'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);

      // Next action for an "assigned" assignment routes to the restaurant.
      expect(find.text('Navigate to Restaurant'), findsOneWidget);

      await tester.tap(find.text('Navigate to Restaurant'));
      await tester.pump();
      expect(navigated, 1);
    });

    testWidgets('shows "Navigate to Customer" once picked up', (tester) async {
      await tester.pumpWidget(
        _themed(
          ActiveAssignmentCard(
            assignment: _offer('o1', status: DeliveryStatus.pickedUp),
            onNavigate: () {},
          ),
        ),
      );

      expect(find.text('Navigate to Customer'), findsOneWidget);
    });
  });

  group('HomeScreen offer experience', () {
    late MockAssignmentRepository assignmentRepo;
    late MockAvailabilityRepository availabilityRepo;
    late MockBackgroundLocationRepository backgroundRepo;

    setUp(() {
      assignmentRepo = MockAssignmentRepository();
      availabilityRepo = MockAvailabilityRepository();
      backgroundRepo = MockBackgroundLocationRepository();

      when(() => assignmentRepo.getActiveAssignment())
          .thenAnswer((_) async => null);
      when(() => backgroundRepo.init()).thenReturn(null);
      when(() => backgroundRepo.startService()).thenAnswer((_) async {});
      when(() => backgroundRepo.stopService()).thenAnswer((_) async {});
    });

    Widget harness({
      required List<DeliveryAssignment> offers,
      bool online = true,
    }) {
      if (online) {
        when(() => availabilityRepo.goOnline())
            .thenAnswer((_) async => const Right(null));
      } else {
        when(() => availabilityRepo.goOnline())
            .thenThrow(Exception('offline'));
      }

      return ProviderScope(
        overrides: [
          assignmentRepositoryProvider.overrideWithValue(assignmentRepo),
          availabilityRepositoryProvider.overrideWithValue(availabilityRepo),
          backgroundLocationRepositoryProvider.overrideWithValue(backgroundRepo),
          pendingOffersProvider.overrideWith((ref) => Stream.value(offers)),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      );
    }

    testWidgets('offline shows the go-online empty state (Req 7.1)',
        (tester) async {
      await tester.pumpWidget(harness(offers: const [], online: false));
      await tester.pumpAndSettle();

      expect(find.text("You're offline"), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Go online'), findsOneWidget);
      expect(find.byType(OfferCard), findsNothing);
    });

    testWidgets('online with no offers shows the waiting empty state '
        '(Req 7.2)', (tester) async {
      await tester.pumpWidget(harness(offers: const []));
      await tester.pumpAndSettle();

      expect(find.text("You're online"), findsOneWidget);
      expect(find.text('Waiting for nearby orders...'), findsOneWidget);
      expect(find.byType(OfferCard), findsNothing);
    });

    testWidgets('a new offer animates in with a slide entrance (Req 7.4)',
        (tester) async {
      // A controllable poll stream so the offer's arrival (and thus its
      // entrance animation) is decoupled from availability resolution.
      final offers = StreamController<List<DeliveryAssignment>>();
      addTearDown(offers.close);
      when(() => availabilityRepo.goOnline())
          .thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assignmentRepositoryProvider.overrideWithValue(assignmentRepo),
            availabilityRepositoryProvider.overrideWithValue(availabilityRepo),
            backgroundLocationRepositoryProvider
                .overrideWithValue(backgroundRepo),
            pendingOffersProvider.overrideWith((ref) => offers.stream),
          ],
          child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
        ),
      );

      // Settle to online with no offers yet (waiting state).
      offers.add(const []);
      await tester.pumpAndSettle();
      expect(find.byType(OfferCard), findsNothing);

      // A freshly-polled offer arrives. It takes a couple of zero-duration
      // pumps (which do not advance animation time) to flush the stream event
      // through the provider and rebuild the list with the new card.
      offers.add([_offer('o1')]);
      await tester.pump();
      await tester.pump();
      expect(find.byType(OfferCard), findsOneWidget);

      // The card is wrapped in the entrance transition (Dismissible also
      // contributes its own resting SlideTransitions, so match on behavior).
      final slideFinder = find.ancestor(
        of: find.byType(OfferCard),
        matching: find.byType(SlideTransition),
      );
      expect(slideFinder, findsWidgets);
      expect(
        find.ancestor(
          of: find.byType(OfferCard),
          matching: find.byType(FadeTransition),
        ),
        findsWidgets,
      );

      List<Offset> slideOffsets() => slideFinder
          .evaluate()
          .map((e) => (e.widget as SlideTransition).position.value)
          .toList();

      // On insert the offer is sliding vertically into place (mid-entrance).
      expect(
        slideOffsets().any((offset) => offset.dy.abs() > 0),
        isTrue,
        reason: 'a freshly inserted offer should be sliding in',
      );

      // Once the entrance completes every transition is at rest.
      await tester.pumpAndSettle();
      expect(
        slideOffsets().every((offset) => offset == Offset.zero),
        isTrue,
        reason: 'the entrance should settle to its resting position',
      );
    });

    testWidgets('accepting an offer triggers acceptOffer and shows the active '
        'assignment card (Req 7.5)', (tester) async {
      when(() => assignmentRepo.acceptOffer('o1'))
          .thenAnswer((_) async => const Right(null));
      when(() => assignmentRepo.cacheAssignment(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(harness(offers: [_offer('o1')]));
      await tester.pumpAndSettle();

      expect(find.byType(OfferCard), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Accept'));
      await tester.pumpAndSettle();

      verify(() => assignmentRepo.acceptOffer('o1')).called(1);
      expect(find.byType(ActiveAssignmentCard), findsOneWidget);
      expect(find.byType(OfferCard), findsNothing);
    });

    testWidgets('dismissing an offer removes its card for the session '
        '(Req 7.8)', (tester) async {
      await tester.pumpWidget(harness(offers: [_offer('o1')]));
      await tester.pumpAndSettle();

      expect(find.byType(OfferCard), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Dismiss'));
      await tester.pumpAndSettle();

      expect(find.byType(OfferCard), findsNothing);
      // Falls back to the waiting empty state now that no offers remain.
      expect(find.text("You're online"), findsOneWidget);
    });

    testWidgets('swiping an offer session-dismisses it', (tester) async {
      await tester.pumpWidget(harness(offers: [_offer('o1')]));
      await tester.pumpAndSettle();

      expect(find.byType(OfferCard), findsOneWidget);

      await tester.drag(find.byType(OfferCard), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(find.byType(OfferCard), findsNothing);
    });
  });
}
