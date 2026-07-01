// Widget tests for the checkout delivery-location experience.
//
// Verifies the non-numeric location indicator and the Place-Order gate:
//  - raw latitude/longitude are never shown or editable        (Req 4.1)
//  - a "resolving" indicator shows while locating               (Req 4.4)
//  - a non-numeric confirmation shows once resolved             (Req 4.5)
//  - non-numeric guidance shows and Place Order stays disabled
//    when resolution fails                                       (Req 4.6)
//  - Place Order is disabled until a location resolves           (Req 4.7)
//  - the coordinates submitted are exactly the resolved GPS /
//    geocoding coordinates, never the old defaults or hand-typed
//    values                                                      (Req 4.8)

import 'dart:async';

import 'package:customer_app/core/maps/geocoding_service.dart';
import 'package:customer_app/core/theme/app_theme.dart';
import 'package:customer_app/features/cart/presentation/cart_controller.dart';
import 'package:customer_app/features/checkout/presentation/checkout_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// The legacy hardcoded coordinates the old checkout used as a silent default.
/// They must never be submitted after this change.
const _oldDefaultLat = 25.4486;
const _oldDefaultLng = 78.5696;

/// A fake [GeolocatorPlatform] with controllable permission / position so the
/// on-open GPS resolve is deterministic in tests. Extends the platform
/// interface (its constructor supplies the verification token) so it can be
/// installed as `GeolocatorPlatform.instance`.
class _FakeGeolocator extends GeolocatorPlatform {
  _FakeGeolocator({
    this.permission = LocationPermission.whileInUse,
    Position? position,
    this.checkPermissionGate,
  }) : position = position ?? _defaultPosition();

  LocationPermission permission;
  Position position;

  /// When set, [checkPermission] returns this pending future so a test can hold
  /// the screen in the "resolving" state until it decides to complete it.
  Future<LocationPermission>? checkPermissionGate;

  @override
  Future<LocationPermission> checkPermission() =>
      checkPermissionGate ?? Future.value(permission);

  @override
  Future<LocationPermission> requestPermission() => Future.value(permission);

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    return Future.value(position);
  }

  static Position _defaultPosition() => Position(
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

/// A fake [GeocodingService] returning canned geocode / reverse-geocode results.
class _FakeGeocoding extends GeocodingService {
  _FakeGeocoding({this.geocodeResult, this.reverseResult});

  final LatLng? geocodeResult;
  final String? reverseResult;

  @override
  Future<LatLng?> geocode(String address, {String? regionBias}) async =>
      geocodeResult;

  @override
  Future<String?> reverseGeocode(double latitude, double longitude) async =>
      reverseResult;
}

/// A [CheckoutController] that records the coordinates passed to [placeOrder]
/// instead of hitting the network, so the submitted provenance can be asserted.
class _RecordingCheckoutController extends CheckoutController {
  final List<({String address, double lat, double lng})> calls = [];

  @override
  Future<void> placeOrder({
    required String deliveryAddress,
    required double latitude,
    required double longitude,
  }) async {
    calls.add((address: deliveryAddress, lat: latitude, lng: longitude));
  }
}

void main() {
  // Finders for the three non-numeric indicator states.
  final resolvingText = find.text('Finding your location…');
  final resolvedText = find.text('Delivering to this location');
  final failedText =
      find.text("Couldn't pin your exact spot — we'll use your typed address.");

  ProviderContainer buildContainer({
    required GeocodingService geocoding,
    required _RecordingCheckoutController controller,
  }) {
    final container = ProviderContainer(
      overrides: [
        geocodingServiceProvider.overrideWithValue(geocoding),
        checkoutControllerProvider.overrideWith(() => controller),
      ],
    );
    // A non-empty cart is required for the checkout form to render.
    container.read(cartControllerProvider.notifier).addItem(
          restaurantId: 'r1',
          restaurantName: 'Test Diner',
          menuItemId: 'm1',
          itemName: 'Test Item',
          price: Decimal.fromInt(5),
          quantity: 2,
        );
    return container;
  }

  Widget harness(ProviderContainer container) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const CheckoutScreen(),
        ),
      );

  FilledButton placeOrderButton(WidgetTester tester) =>
      tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Place Order'),
      );

  void expectNoRawCoordinates() {
    // No latitude/longitude entry fields, and the legacy defaults never appear.
    expect(find.widgetWithText(TextField, 'Latitude'), findsNothing);
    expect(find.widgetWithText(TextField, 'Longitude'), findsNothing);
    expect(find.byType(TextField), findsOneWidget); // only the address field
    expect(find.text('$_oldDefaultLat'), findsNothing);
    expect(find.text('$_oldDefaultLng'), findsNothing);
  }

  testWidgets(
      'shows the resolving indicator and disables Place Order while locating',
      (tester) async {
    // Hold the resolve open on a pending permission check so the screen stays
    // in the "resolving" state for the duration of the assertions.
    final gate = Completer<LocationPermission>();
    final geo = _FakeGeolocator(checkPermissionGate: gate.future);
    GeolocatorPlatform.instance = geo;

    final controller = _RecordingCheckoutController();
    final container = buildContainer(
      geocoding: _FakeGeocoding(reverseResult: 'Fake Street'),
      controller: controller,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(harness(container));
    await tester.pump(); // run the post-frame resolve up to the pending gate

    // Req 4.4: a non-numeric resolving indicator with a spinner.
    expect(resolvingText, findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(resolvedText, findsNothing);
    expect(failedText, findsNothing);

    // Req 4.7: Place Order disabled while unresolved.
    expect(placeOrderButton(tester).onPressed, isNull);
    expectNoRawCoordinates();

    // Let the resolve finish cleanly so no work is left pending at teardown.
    gate.complete(LocationPermission.whileInUse);
    await tester.pumpAndSettle();
    expect(resolvedText, findsOneWidget);
  });

  testWidgets(
      'resolves via GPS, shows the confirmation, and submits the GPS '
      'coordinates', (tester) async {
    GeolocatorPlatform.instance = _FakeGeolocator(
      permission: LocationPermission.whileInUse,
      position: _FakeGeolocator._defaultPosition(), // 12.9611, 77.6387
    );

    final controller = _RecordingCheckoutController();
    final container = buildContainer(
      geocoding: _FakeGeocoding(reverseResult: 'Fake Street'),
      controller: controller,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(harness(container));
    await tester.pumpAndSettle();

    // Req 4.5: non-numeric confirmation, with the reverse-geocoded address.
    expect(resolvedText, findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('Fake Street'), findsOneWidget);
    expectNoRawCoordinates();

    // Gate is enabled once address + coordinates are present.
    expect(placeOrderButton(tester).onPressed, isNotNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Place Order'));
    await tester.pump();

    // Req 4.8: the submitted coordinates are exactly the resolved GPS values,
    // never the old hardcoded defaults.
    expect(controller.calls, hasLength(1));
    final call = controller.calls.single;
    expect(call.address, 'Fake Street');
    expect(call.lat, 12.9611);
    expect(call.lng, 77.6387);
    expect(call.lat, isNot(_oldDefaultLat));
    expect(call.lng, isNot(_oldDefaultLng));
  });

  testWidgets(
      'keeps Place Order disabled and shows guidance when GPS resolution fails',
      (tester) async {
    // Permission denied on both check and request → resolution fails.
    GeolocatorPlatform.instance =
        _FakeGeolocator(permission: LocationPermission.denied);

    final controller = _RecordingCheckoutController();
    final container = buildContainer(
      geocoding: _FakeGeocoding(),
      controller: controller,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(harness(container));
    await tester.pumpAndSettle();

    // Req 4.6: non-numeric guidance; no confirmation.
    expect(failedText, findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(resolvedText, findsNothing);
    expectNoRawCoordinates();

    // Even with an address typed, the gate stays disabled while coords are
    // unresolved (Req 4.7), so nothing can be submitted.
    await tester.enterText(find.byType(TextField), '42 Placeholder Rd');
    await tester.pump();
    expect(placeOrderButton(tester).onPressed, isNull);
    expect(controller.calls, isEmpty);

    // Flush the transient permission-denied SnackBar timer.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'resolves via typed-address geocoding and submits the geocoded '
      'coordinates', (tester) async {
    // GPS resolves first (no SnackBar), then the typed address overrides it.
    GeolocatorPlatform.instance = _FakeGeolocator(
      permission: LocationPermission.whileInUse,
      position: _FakeGeolocator._defaultPosition(),
    );

    final controller = _RecordingCheckoutController();
    final container = buildContainer(
      geocoding: _FakeGeocoding(
        reverseResult: 'GPS Address',
        geocodeResult: const LatLng(40.0, -73.0),
      ),
      controller: controller,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(harness(container));
    await tester.pumpAndSettle();
    expect(resolvedText, findsOneWidget);

    // Type a different address and geocode it, overriding the GPS coordinates.
    await tester.enterText(find.byType(TextField), '10 Main St');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Let the confirmation SnackBar auto-dismiss so it does not obscure the
    // Place Order button when we tap it below.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(resolvedText, findsOneWidget);
    expect(placeOrderButton(tester).onPressed, isNotNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Place Order'));
    await tester.pump();

    // Req 4.8: submitted coordinates come from geocoding (40, -73), not from
    // GPS and not from the old defaults.
    expect(controller.calls, hasLength(1));
    final call = controller.calls.single;
    expect(call.address, '10 Main St');
    expect(call.lat, 40.0);
    expect(call.lng, -73.0);
    expect(call.lat, isNot(12.9611));
    expect(call.lat, isNot(_oldDefaultLat));
    expect(call.lng, isNot(_oldDefaultLng));
  });
}
