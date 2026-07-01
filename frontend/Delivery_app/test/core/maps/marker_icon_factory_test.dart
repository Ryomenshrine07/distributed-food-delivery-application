// Example/widget tests for the custom rider marker (Item 1, Delivery app).
//
// Covers the non-property behaviours of the rider puck marker:
//   * the default marker is shown until the puck is ready (Req 1.3), and once
//     ready the puck replaces the default (Req 1.2, 1.4);
//   * the live MarkerAnimator bearing and the centered (0.5, 0.5) anchor are
//     preserved (Req 1.5);
//   * a render failure surfaces without crashing and leaves the default marker
//     usable, and the failed entry is evicted so a later frame can retry
//     (Req 1.9);
//   * the puck fill derives from the `riderMarker` token (Req 1.7 / 8.4).
//
// **Validates: Requirements 1.2, 1.3, 1.5, 1.9**

import 'dart:typed_data';

import 'package:delivery_app/core/maps/marker_icon_factory.dart';
import 'package:delivery_app/core/theme/app_tokens.dart';
import 'package:delivery_app/core/theme/brand_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fallback =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  final puck =
      BitmapDescriptor.bytes(Uint8List.fromList(<int>[1, 2, 3]), imagePixelRatio: 2);
  const position = LatLng(12.9863, 77.7349);

  group('buildRiderMarker', () {
    test('uses the default fallback while the puck is not ready (Req 1.3)', () {
      final marker = buildRiderMarker(
        position: position,
        bearing: 42,
        fallback: fallback,
        puck: null,
        infoWindowTitle: 'You',
      );
      expect(identical(marker.icon, fallback), isTrue);
      expect(marker.markerId, const MarkerId('rider'));
    });

    test('shows the custom puck once it is ready (Req 1.2, 1.4)', () {
      final marker = buildRiderMarker(
        position: position,
        bearing: 42,
        fallback: fallback,
        puck: puck,
        infoWindowTitle: 'You',
      );
      expect(identical(marker.icon, puck), isTrue);
    });

    test('preserves the animator bearing and centered anchor (Req 1.5)', () {
      final marker = buildRiderMarker(
        position: position,
        bearing: 137.5,
        fallback: fallback,
        puck: puck,
        infoWindowTitle: 'You',
      );
      expect(marker.rotation, 137.5);
      expect(marker.anchor, const Offset(0.5, 0.5));
      expect(marker.position, position);
    });

    test('carries the navigation "You" info window title', () {
      final marker = buildRiderMarker(
        position: position,
        bearing: 0,
        fallback: fallback,
        infoWindowTitle: 'You',
      );
      expect(marker.infoWindow.title, 'You');
    });
  });

  group('MarkerIconFactory', () {
    test('puck fill derives from the riderMarker token (Req 1.7)', () async {
      Color? capturedColor;
      Future<BitmapDescriptor> recordingRenderer(PuckRequest r) async {
        capturedColor = r.color;
        return puck;
      }

      final factory = MarkerIconFactory(renderer: recordingRenderer);
      await factory.vehiclePuck(
        color: AppTokens.light().riderMarker,
        devicePixelRatio: 3,
      );

      expect(capturedColor, AppTokens.light().riderMarker);
      // The token itself is the documented brand rider color.
      expect(AppTokens.light().riderMarker, BrandPalette.riderMarker);
    });

    test(
        'a render failure surfaces as an error, keeps the default marker '
        'usable, and evicts so a later frame retries (Req 1.9)', () async {
      var calls = 0;
      Future<BitmapDescriptor> flakyRenderer(PuckRequest r) async {
        calls++;
        if (calls == 1) {
          throw StateError('encode failed');
        }
        return puck;
      }

      final factory = MarkerIconFactory(renderer: flakyRenderer);
      const color = Color(0xFF2B9E49);

      // First render fails; the factory does not crash and propagates the error
      // so the caller can keep the default marker.
      await expectLater(
        factory.vehiclePuck(color: color, devicePixelRatio: 2),
        throwsA(isA<StateError>()),
      );

      // The screen's fallback: a null puck still builds a valid marker using
      // the default descriptor.
      final marker = buildRiderMarker(
        position: position,
        bearing: 0,
        fallback: fallback,
        puck: null,
        infoWindowTitle: 'You',
      );
      expect(identical(marker.icon, fallback), isTrue);

      // The failed entry was evicted, so a later request re-renders and wins.
      final result =
          await factory.vehiclePuck(color: color, devicePixelRatio: 2);
      expect(calls, 2);
      expect(identical(result, puck), isTrue);
    });
  });
}
