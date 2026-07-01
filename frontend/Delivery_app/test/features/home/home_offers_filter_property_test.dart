// Feature: ui-modernization, Property 4: Session-local offer dismissal filter
//
// Property 4: Session-local offer dismissal filter
// For any set of polled offers and any set of session-dismissed order ids, the
// offers displayed by the Delivery_App are exactly those polled offers whose
// order id is NOT in the dismissed set (order preserved).
//
// Soundness is checked independently of the implementation (every displayed
// offer is one of the polled offers and is not in the dismissed set).
// Completeness + order is checked against a specification-derived oracle: the
// in-order retention of every polled offer whose id is not dismissed.
//
// **Validates: Requirements 7.8, 7.9**

import 'package:delivery_app/features/assignment/domain/entities/delivery_assignment.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_status.dart';
import 'package:delivery_app/features/home/presentation/providers/home_offers_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/generators.dart';
import '../../support/pbt.dart';

DeliveryAssignment _offer(String orderId) => DeliveryAssignment(
      id: 'assign-$orderId',
      orderId: orderId,
      restaurantLatitude: 0,
      restaurantLongitude: 0,
      status: DeliveryStatus.pending,
    );

typedef _Case = ({List<DeliveryAssignment> offers, Set<String> dismissed});

void main() {
  group(propertyTag(4, 'Session-local offer dismissal filter'), () {
    test(
      'displayed offers are exactly the polled offers whose orderId is not '
      'dismissed (>=100 iterations)',
      () {
        forAll<_Case>(
          (random) {
            // A small pool of ids so offers and the dismissed set overlap
            // meaningfully (and so duplicate order ids can occur).
            final poolSize = Gen.intInRange(0, 8)(random);
            final pool = [
              for (var i = 0; i < poolSize; i++) Gen.id(length: 4)(random),
            ];

            // Offers drawn from the pool.
            final offers = <DeliveryAssignment>[];
            final offerCount = Gen.intInRange(0, 10)(random);
            for (var i = 0; i < offerCount && pool.isNotEmpty; i++) {
              offers.add(_offer(pool[random.nextInt(pool.length)]));
            }

            // Dismissed: a random subset of the pool plus some ids that appear
            // in no offer (exercising the "dismiss an absent id" case).
            final dismissed = <String>{
              for (final id in pool)
                if (random.nextBool()) id,
            };
            final extra = Gen.intInRange(0, 3)(random);
            for (var i = 0; i < extra; i++) {
              dismissed.add(Gen.id(length: 4)(random));
            }

            return (offers: offers, dismissed: dismissed);
          },
          (c) {
            final visible = visibleOffers(c.offers, c.dismissed);

            // Soundness: every displayed offer is a polled offer and is NOT in
            // the dismissed set.
            for (final offer in visible) {
              expect(
                c.offers,
                contains(offer),
                reason: 'a displayed offer must come from the polled offers',
              );
              expect(
                c.dismissed.contains(offer.orderId),
                isFalse,
                reason: 'a dismissed offer must never be displayed',
              );
            }

            // Completeness + order: equals the in-order retention of every
            // polled offer whose id is not dismissed.
            final expected = [
              for (final offer in c.offers)
                if (!c.dismissed.contains(offer.orderId)) offer,
            ];
            expect(visible, expected);
          },
          describe: (c) =>
              'offers=${c.offers.map((o) => o.orderId).toList()}, '
              'dismissed=${c.dismissed}',
        );
      },
    );

    test('empty dismissed set displays all polled offers', () {
      final offers = [_offer('a'), _offer('b'), _offer('c')];
      expect(visibleOffers(offers, <String>{}), offers);
    });

    test('dismissing every offer id yields no displayed offers', () {
      final offers = [_offer('a'), _offer('b')];
      expect(visibleOffers(offers, {'a', 'b'}), isEmpty);
    });
  });
}
