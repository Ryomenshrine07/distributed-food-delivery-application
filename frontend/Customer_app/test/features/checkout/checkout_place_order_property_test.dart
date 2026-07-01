// Feature: ui-modernization, Property 5: Checkout Place-Order gate and coordinate provenance
//
// Property 5: Checkout Place-Order gate and coordinate provenance
// For any checkout state, the "Place Order" action is enabled if and only if a
// non-empty address is present AND both latitude and longitude are resolved
// (non-null); and whenever an order is placed, the submitted coordinates equal
// the GPS/geocoding-resolved internal coordinates and are never default or
// hand-typed values.
//
// The oracle is derived directly from the specification (enabled iff address
// present and both coords non-null; submitted coords == resolved coords) rather
// than from the implementation. The two pure seams under test —
// `canPlaceOrder` (the enablement gate) and `resolvedOrderCoordinates` (the
// coordinate provenance) — are exercised across the whole state space of
// present/absent address and resolved/unresolved coordinates, including the
// old default values (25.4486 / 78.5696) fed as *resolved* inputs to prove the
// functions pass through whatever resolved and never inject a fallback.
//
// **Validates: Requirements 4.7, 4.8**

import 'package:customer_app/features/checkout/presentation/checkout_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/generators.dart';
import '../../support/pbt.dart';

/// A generated checkout coordinate/address state.
typedef _CheckoutState = ({bool hasAddress, double? lat, double? lng});

void main() {
  group(propertyTag(5, 'Checkout Place-Order gate and coordinate provenance'),
      () {
    // Occasionally feed the *old* hardcoded defaults as genuinely-resolved
    // coordinates so the provenance assertions prove the pure functions pass
    // through the resolved value and never substitute a constant of their own.
    const oldDefaultLat = 25.4486;
    const oldDefaultLng = 78.5696;

    test(
        'gate is enabled iff address present and both coords resolved, and '
        'submitted coords equal the resolved coords (>=100 iterations)', () {
      forAll<_CheckoutState>(
        (random) {
          final hasAddress = Gen.boolean()(random);
          // Mix realistic coordinates, the legacy defaults, and null
          // (unresolved) so both branches of the gate and the provenance seam
          // are covered.
          final lat = Gen.nullable(
            Gen.oneOf<double>([
              Gen.doubleInRange(-90, 90)(random),
              oldDefaultLat,
            ]),
            nullProbability: 0.35,
          )(random);
          final lng = Gen.nullable(
            Gen.oneOf<double>([
              Gen.doubleInRange(-180, 180)(random),
              oldDefaultLng,
            ]),
            nullProbability: 0.35,
          )(random);
          return (hasAddress: hasAddress, lat: lat, lng: lng);
        },
        (s) {
          final enabled =
              canPlaceOrder(hasAddress: s.hasAddress, lat: s.lat, lng: s.lng);

          // Req 4.7: the gate is exactly (address present AND both coords
          // resolved). Encodes the "if and only if" from Property 5.
          expect(
            enabled,
            s.hasAddress && s.lat != null && s.lng != null,
            reason: 'gate must be (hasAddress && lat != null && lng != null)',
          );

          final coords = resolvedOrderCoordinates(s.lat, s.lng);

          // Req 4.8 (provenance): coordinates exist iff both inputs are
          // resolved, and when present they equal the resolved inputs exactly —
          // there is no default or hand-typed fallback.
          if (s.lat == null || s.lng == null) {
            expect(coords, isNull,
                reason: 'no coordinates when the location is unresolved');
          } else {
            expect(coords, isNotNull);
            expect(coords!.latitude, s.lat,
                reason: 'submitted latitude must equal the resolved latitude');
            expect(coords.longitude, s.lng,
                reason: 'submitted longitude must equal the resolved longitude');
          }

          // Req 4.7 + 4.8 together: whenever the order CAN be placed, the
          // coordinates it would submit are present and are exactly the
          // resolved internal coordinates (never null, never a default).
          if (enabled) {
            expect(coords, isNotNull);
            expect(coords!.latitude, s.lat);
            expect(coords.longitude, s.lng);
          }
        },
        describe: (s) =>
            'hasAddress=${s.hasAddress}, lat=${s.lat}, lng=${s.lng}',
      );
    });
  });
}
