// Cross-cutting accessibility tests for the Customer app (Task 10.1).
//
// Covers, for the controls introduced/modified by this feature:
//  - >=48x48 tap targets AND accessibility labels on cart / call / Place-Order
//    controls                                                    (Req 9.1, 9.2)
//  - redesigned text rows stay readable (no overflow/clipping) at a 200% OS
//    text scale                                                   (Req 9.4)
//  - the documented brand-on-surface token pairs meet the WCAG AA contrast
//    ratio (computed against the BrandPalette constants)          (Req 9.3)
//
// Note (Req 9.3): automated contrast checks cover the documented token pairs
// only. Full WCAG conformance still requires manual assistive-technology
// testing and expert review, which is out of scope for an automated suite.

import 'dart:math' as math;

import 'package:customer_app/core/maps/geocoding_service.dart';
import 'package:customer_app/core/theme/app_theme.dart';
import 'package:customer_app/core/theme/brand_palette.dart';
import 'package:customer_app/core/widgets/call_button.dart';
import 'package:customer_app/features/cart/presentation/cart_controller.dart';
import 'package:customer_app/features/cart/presentation/widgets/cart_icon_button.dart';
import 'package:customer_app/features/checkout/presentation/checkout_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ---------------------------------------------------------------------------
// WCAG relative-luminance / contrast-ratio helper (small, self-contained).
// ---------------------------------------------------------------------------

/// Relative luminance of [color] per WCAG 2.1
/// (https://www.w3.org/TR/WCAG21/#dfn-relative-luminance). Channel accessors
/// `.r/.g/.b` are already normalized doubles in [0, 1].
double _relativeLuminance(Color color) {
  double linearize(double channel) => channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * linearize(color.r) +
      0.7152 * linearize(color.g) +
      0.0722 * linearize(color.b);
}

/// WCAG contrast ratio between [foreground] and [background] (>= 1.0).
double _contrastRatio(Color foreground, Color background) {
  final lumFg = _relativeLuminance(foreground);
  final lumBg = _relativeLuminance(background);
  final lighter = math.max(lumFg, lumBg);
  final darker = math.min(lumFg, lumBg);
  return (lighter + 0.05) / (darker + 0.05);
}

/// A documented brand-on-surface color pair and the WCAG AA ratio it must meet.
/// `minRatio` is 4.5:1 for normal text and 3.0:1 for large text / UI components.
class _BrandPair {
  const _BrandPair(this.name, this.foreground, this.background, this.minRatio);
  final String name;
  final Color foreground;
  final Color background;
  final double minRatio;
}

void main() {
  // The documented on-color for the brand/semantic fills is white
  // (AppTokens.onSuccess/onWarning/onInfo and the M3 onPrimary for the header).
  const white = Color(0xFFFFFFFF);

  // Adds a cart line so the checkout form renders and a location can resolve.
  void seedCart(ProviderContainer container) {
    container.read(cartControllerProvider.notifier).addItem(
          restaurantId: 'r1',
          restaurantName: 'Test Diner',
          menuItemId: 'm1',
          itemName: 'Test Item',
          price: Decimal.fromInt(5),
          quantity: 2,
        );
  }

  ProviderContainer checkoutContainer() {
    final container = ProviderContainer(
      overrides: [
        geocodingServiceProvider
            .overrideWithValue(_FakeGeocoding(reverseResult: 'Fake Street')),
      ],
    );
    seedCart(container);
    return container;
  }

  /// Pumps the checkout screen with a successful GPS resolve. When
  /// [textScaler] is provided the whole app is rendered at that OS text scale.
  Future<void> pumpCheckout(
    WidgetTester tester,
    ProviderContainer container, {
    double? textScaler,
  }) async {
    GeolocatorPlatform.instance = _FakeGeolocator();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const CheckoutScreen(),
          builder: textScaler == null
              ? null
              : (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(textScaler)),
                    child: child!,
                  ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Tap targets and labels (Req 9.1, 9.2)', () {
    testWidgets('cart control has a >=48x48 target and a "Cart, N items" label',
        (tester) async {
      final handle = tester.ensureSemantics();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(cartControllerProvider.notifier).addItem(
            restaurantId: 'r1',
            restaurantName: 'Test Diner',
            menuItemId: 'm1',
            itemName: 'Test Item',
            price: Decimal.fromInt(5),
            quantity: 3,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              appBar: null,
              body: Center(child: CartIconButton()),
            ),
          ),
        ),
      );
      await tester.pump();

      final size = tester.getSize(find.byType(IconButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));

      final semantics = tester.getSemantics(find.byType(CartIconButton));
      expect(semantics.label, 'Cart, 3 items');
      handle.dispose();
    });

    testWidgets('call control has a >=48x48 target and a "Call" label',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: CallButton(phoneNumber: '5550102020')),
          ),
        ),
      );

      expect(find.byTooltip('Call'), findsOneWidget);
      final size = tester.getSize(find.byType(IconButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('Place Order control has a >=48 tall target and a label',
        (tester) async {
      final container = checkoutContainer();
      addTearDown(container.dispose);

      await pumpCheckout(tester, container);

      final placeOrder = find.widgetWithText(FilledButton, 'Place Order');
      expect(placeOrder, findsOneWidget);
      // The visible text is the button's accessible name.
      expect(find.text('Place Order'), findsOneWidget);
      expect(
        tester.getSize(placeOrder).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('200% text scale readability (Req 9.4)', () {
    testWidgets('redesigned checkout rows do not clip at a 2.0 text scale',
        (tester) async {
      final container = checkoutContainer();
      addTearDown(container.dispose);

      await pumpCheckout(tester, container, textScaler: 2.0);

      // No RenderFlex overflow (or other layout exception) was reported while
      // laying out the redesigned rows at 200% text scale.
      expect(tester.takeException(), isNull);
      // The rows are still present and readable.
      expect(find.text('Place Order'), findsOneWidget);
      expect(find.text('Delivering to this location'), findsOneWidget);
    });
  });

  group('Brand-on-surface contrast meets WCAG AA (Req 9.3)', () {
    test('documented BrandPalette pairs meet their AA threshold', () {
      const pairs = <_BrandPair>[
        // Req 5.5 header: title/status/icons (large text + UI) on brand green.
        _BrandPair('white on brandPrimary (header)', white,
            BrandPalette.brandPrimary, 3.0),
        // Pressed/scrim brand shade carries readable white text (normal text).
        _BrandPair('white on brandPrimaryDark', white,
            BrandPalette.brandPrimaryDark, 4.5),
        // Semantic status fills with their documented white on-color.
        _BrandPair(
            'onSuccess on success', white, BrandPalette.successLight, 4.5),
        // Orange warning fill reads at AA for large text / UI components.
        _BrandPair('onWarning on warning', white, BrandPalette.warningLight, 3.0),
        _BrandPair('onError on error', white, BrandPalette.errorLight, 4.5),
        _BrandPair('onInfo on info', white, BrandPalette.infoLight, 4.5),
      ];

      for (final pair in pairs) {
        final ratio = _contrastRatio(pair.foreground, pair.background);
        expect(
          ratio,
          greaterThanOrEqualTo(pair.minRatio),
          reason: '${pair.name}: ${ratio.toStringAsFixed(2)}:1 '
              '(min ${pair.minRatio}:1)',
        );
      }
    });

    test('the rendered header pair (onPrimary on primary) meets normal-text AA',
        () {
      for (final scheme in [
        AppTheme.light().colorScheme,
        AppTheme.dark().colorScheme,
      ]) {
        expect(
          _contrastRatio(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(4.5),
        );
      }
    });
  });
}

/// A [GeolocatorPlatform] fake that grants permission and returns a fixed
/// position so the checkout GPS resolve is deterministic (no platform channel).
class _FakeGeolocator extends GeolocatorPlatform {
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async =>
      Position(
        latitude: 12.9611,
        longitude: 77.6387,
        timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        accuracy: 5,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
}

/// A [GeocodingService] fake returning a canned reverse-geocoded address.
class _FakeGeocoding extends GeocodingService {
  _FakeGeocoding({this.reverseResult});

  final String? reverseResult;

  @override
  Future<LatLng?> geocode(String address, {String? regionBias}) async => null;

  @override
  Future<String?> reverseGeocode(double latitude, double longitude) async =>
      reverseResult;
}
