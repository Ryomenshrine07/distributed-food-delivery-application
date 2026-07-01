// Regression tests for [TrackingSocket]'s last-known-location cache.
//
// The bug: when the customer left the live tracking screen and came back while
// the rider was en route, the fresh `_OrderTrackingView` state reset
// `_hasRiderLocation` to false, so the rider marker stayed blank until the next
// socket emission (which can be several seconds away, or not arrive promptly).
//
// The fix has the singleton [TrackingSocket] retain the most recent rider
// position, scoped to the order being tracked, so the re-entering screen can
// seed the marker immediately from [TrackingSocket.lastLocationFor].
//
// These tests drive the retain / scope / invalidate / survive-disconnect
// contract directly through the small internal seams ([selectOrder],
// [handleLocationFrame]) so no live STOMP client or WebSocket is required.

import 'dart:convert';

import 'package:customer_app/core/websocket/tracking_socket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String frameFor(
    String orderId, {
    double lat = 12.9,
    double lng = 77.6,
    int timestamp = 1700000000000,
  }) {
    return jsonEncode({
      'riderId': 'rider-1',
      'orderId': orderId,
      'latitude': lat,
      'longitude': lng,
      'timestamp': timestamp,
    });
  }

  group('TrackingSocket last-location cache', () {
    test('retains the last received location, scoped to the tracked order', () {
      final socket = TrackingSocket();
      addTearDown(socket.disconnect);

      // Enter order A and receive one live update (as the STOMP callback would).
      socket.selectOrder('A');
      socket.handleLocationFrame(frameFor('A', lat: 12.34, lng: 56.78));

      final cached = socket.lastLocationFor('A');
      expect(cached, isNotNull);
      expect(cached!.latitude, 12.34);
      expect(cached.longitude, 56.78);

      // The cache is scoped to the current order: it never leaks to another id.
      expect(socket.lastLocationFor('B'), isNull);
    });

    test('lastLocationFor is null before any update arrives', () {
      final socket = TrackingSocket();
      addTearDown(socket.disconnect);

      socket.selectOrder('A');
      expect(socket.lastLocationFor('A'), isNull);
    });

    test('a later update for the same order replaces the cached position', () {
      final socket = TrackingSocket();
      addTearDown(socket.disconnect);

      socket.selectOrder('A');
      socket.handleLocationFrame(frameFor('A', lat: 1.0, lng: 1.0));
      socket.handleLocationFrame(frameFor('A', lat: 2.0, lng: 2.0));

      final cached = socket.lastLocationFor('A');
      expect(cached!.latitude, 2.0);
      expect(cached.longitude, 2.0);
    });

    test('re-selecting the SAME order keeps the cached location', () {
      final socket = TrackingSocket();
      addTearDown(socket.disconnect);

      socket.selectOrder('A');
      socket.handleLocationFrame(frameFor('A'));
      expect(socket.lastLocationFor('A'), isNotNull);

      // Navigating away and back reconnects to the same order; the cache must
      // survive so the marker can be seeded immediately on re-entry.
      socket.selectOrder('A');
      expect(socket.lastLocationFor('A'), isNotNull);
    });

    test('selecting a DIFFERENT order resets the cache', () {
      final socket = TrackingSocket();
      addTearDown(socket.disconnect);

      socket.selectOrder('A');
      socket.handleLocationFrame(frameFor('A'));
      expect(socket.lastLocationFor('A'), isNotNull);

      // Connecting to a different order invalidates the previous order's cache.
      socket.selectOrder('B');
      expect(socket.lastLocationFor('A'), isNull);
      expect(socket.lastLocationFor('B'), isNull);
    });

    test('disconnect retains the cache so a quick re-entry can reseed', () {
      final socket = TrackingSocket();
      addTearDown(socket.disconnect);

      socket.selectOrder('A');
      socket.handleLocationFrame(frameFor('A', lat: 5.0, lng: 6.0));
      expect(socket.lastLocationFor('A'), isNotNull);

      // dispose() on the screen calls disconnect(); the cache must persist so a
      // fast navigate-back still has a last known position to seed from.
      socket.disconnect();

      final cached = socket.lastLocationFor('A');
      expect(cached, isNotNull);
      expect(cached!.latitude, 5.0);
      expect(cached.longitude, 6.0);
    });

    test('a malformed or null frame is ignored and does not corrupt the cache',
        () {
      final socket = TrackingSocket();
      addTearDown(socket.disconnect);

      socket.selectOrder('A');
      socket.handleLocationFrame(frameFor('A', lat: 1.0, lng: 2.0));
      socket.handleLocationFrame('not json');
      socket.handleLocationFrame('{"missing":"fields"}');
      socket.handleLocationFrame(null);

      final cached = socket.lastLocationFor('A');
      expect(cached, isNotNull);
      expect(cached!.latitude, 1.0);
      expect(cached.longitude, 2.0);
    });

    test('still publishes each received update on locationStream', () async {
      final socket = TrackingSocket();
      addTearDown(socket.disconnect);
      socket.selectOrder('A');

      final received = <RiderLocationUpdate>[];
      final sub = socket.locationStream.listen(received.add);
      addTearDown(sub.cancel);

      socket.handleLocationFrame(frameFor('A', lat: 9.9, lng: 8.8));
      // Broadcast stream events are delivered on a microtask; let it dispatch.
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(received.single.latitude, 9.9);
      expect(received.single.longitude, 8.8);
    });
  });
}
