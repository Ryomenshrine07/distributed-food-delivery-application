// Feature: ui-modernization, Property 6: Marker bitmap cache determinism
//
// Property 6: Marker bitmap cache determinism
// For any sequence of marker requests, two requests with identical
// (icon, color, sizeDp, devicePixelRatio) keys return the same cached
// BitmapDescriptor, and the painter runs at most once per distinct key.
//
// The byte-rendering step is injected as a *counting* fake renderer, so the
// caching/keying guarantee is verified deterministically without a live GPU or
// headless-render support. Each fake render returns a distinct BitmapDescriptor
// instance, so mis-caching (handing back a different instance for a repeated
// key, or re-rendering an already-cached key) is detectable by identity.
//
// **Validates: Requirements 1.8**

import 'dart:typed_data';

import 'package:delivery_app/core/maps/marker_icon_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../support/generators.dart';
import '../../support/pbt.dart';

/// A request drawn from a small pool of keys so repeats (cache hits) are
/// frequent across the generated sequence.
class _Req {
  const _Req(this.icon, this.color, this.sizeDp, this.dpr);
  final IconData icon;
  final Color color;
  final double sizeDp;
  final double dpr;

  String get keyString => '${icon.codePoint}-${color.toARGB32()}-$sizeDp-$dpr';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A constrained key space (2 icons x 3 colors x 3 sizes x 3 dprs = 54 keys)
  // guarantees frequent collisions over >=100 iterations.
  const iconPool = <IconData>[Icons.two_wheeler, Icons.pedal_bike];
  const colorPool = <Color>[
    Color(0xFF2B9E49),
    Color(0xFF1565C0),
    Color(0xFFE65100),
  ];
  const sizePool = <double>[40, 44, 48];
  const dprPool = <double>[1, 2, 3];

  Generator<_Req> genReq() => (random) => _Req(
        Gen.oneOf(iconPool)(random),
        Gen.oneOf(colorPool)(random),
        Gen.oneOf(sizePool)(random),
        Gen.oneOf(dprPool)(random),
      );

  group(propertyTag(6, 'Marker bitmap cache determinism'), () {
    test(
        'identical keys reuse one cached bitmap and the painter runs at most '
        'once per distinct key (>=100 iterations)', () {
      var paintCount = 0;
      Future<BitmapDescriptor> countingRenderer(PuckRequest r) async {
        paintCount++;
        // A fresh, distinct instance per invocation so mis-caching is visible.
        return BitmapDescriptor.bytes(
          Uint8List.fromList(<int>[paintCount % 256]),
          imagePixelRatio: r.devicePixelRatio,
        );
      }

      final factory = MarkerIconFactory(renderer: countingRenderer);
      final firstFutureByKey = <String, Future<BitmapDescriptor>>{};

      forAll<_Req>(
        genReq(),
        (req) {
          final future = factory.vehiclePuck(
            color: req.color,
            icon: req.icon,
            sizeDp: req.sizeDp,
            devicePixelRatio: req.dpr,
          );

          if (firstFutureByKey.containsKey(req.keyString)) {
            // A repeated key must hand back the very same cached future (hence
            // the same resolved BitmapDescriptor) without re-rendering.
            expect(
              identical(future, firstFutureByKey[req.keyString]),
              isTrue,
              reason: 'repeat request for ${req.keyString} must reuse the '
                  'cached instance',
            );
          } else {
            firstFutureByKey[req.keyString] = future;
          }

          // The painter runs exactly once per distinct key seen so far — i.e.
          // at most once per key across the whole generated sequence.
          expect(
            paintCount,
            firstFutureByKey.length,
            reason: 'painter must run at most once per distinct key',
          );
        },
        describe: (req) => req.keyString,
      );
    });

    test('resolved descriptors are identical for identical keys', () async {
      var paintCount = 0;
      Future<BitmapDescriptor> countingRenderer(PuckRequest r) async {
        paintCount++;
        return BitmapDescriptor.bytes(
          Uint8List.fromList(<int>[paintCount % 256]),
          imagePixelRatio: r.devicePixelRatio,
        );
      }

      final factory = MarkerIconFactory(renderer: countingRenderer);
      const color = Color(0xFF2B9E49);

      final a = await factory.vehiclePuck(color: color, devicePixelRatio: 2);
      final b = await factory.vehiclePuck(color: color, devicePixelRatio: 2);
      expect(identical(a, b), isTrue);
      expect(paintCount, 1);

      // A different dpr is a different key -> a fresh render.
      final c = await factory.vehiclePuck(color: color, devicePixelRatio: 3);
      expect(identical(a, c), isFalse);
      expect(paintCount, 2);

      // clearCache() forces a re-render for a previously-cached key.
      factory.clearCache();
      final d = await factory.vehiclePuck(color: color, devicePixelRatio: 2);
      expect(identical(a, d), isFalse);
      expect(paintCount, 3);
    });
  });
}
