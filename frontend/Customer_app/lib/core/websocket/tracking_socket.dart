import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../constants/app_constants.dart';

final trackingSocketProvider = Provider<TrackingSocket>((ref) {
  return TrackingSocket();
});

class RiderLocationUpdate {
  final String riderId;
  final String? orderId;
  final double latitude;
  final double longitude;
  final int timestamp;

  RiderLocationUpdate({
    required this.riderId,
    this.orderId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory RiderLocationUpdate.fromJson(Map<String, dynamic> json) {
    return RiderLocationUpdate(
      riderId: json['riderId'] as String,
      orderId: json['orderId'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
    );
  }
}

class TrackingSocket {
  StompClient? _stompClient;
  final _locationController = StreamController<RiderLocationUpdate>.broadcast();

  /// The order currently being tracked. Scopes [lastLocationFor] so a cached
  /// position is never handed out for a different order.
  String? _currentOrderId;

  /// The most recent rider location received for [_currentOrderId], retained so
  /// a re-entering screen can paint the marker immediately (before the next
  /// live update arrives) instead of showing a blank map.
  RiderLocationUpdate? _lastLocation;

  Stream<RiderLocationUpdate> get locationStream => _locationController.stream;

  /// Returns the last known rider location for [orderId], or null when none has
  /// arrived yet or the socket has since switched to a different order.
  RiderLocationUpdate? lastLocationFor(String orderId) =>
      _currentOrderId == orderId ? _lastLocation : null;

  void connect(String orderId, {String? token}) {
    selectOrder(orderId);

    if (_stompClient != null && _stompClient!.isActive) {
      return;
    }

    final wsUrl = AppConstants.baseUrl.replaceFirst('http', 'ws') + '/ws/tracking';

    final headers = {
      'client-id': 'customer-app-$orderId',
      'ngrok-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (StompFrame frame) {
          debugPrint('Connected to STOMP');
          _stompClient?.subscribe(
            destination: '/topic/orders/$orderId/location',
            callback: (StompFrame frame) => handleLocationFrame(frame.body),
          );
        },
        onWebSocketError: (dynamic error) => debugPrint('WebSocket Error: $error'),
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
      ),
    );

    _stompClient?.activate();
  }

  /// Records [orderId] as the order being tracked, clearing any location cached
  /// for a previous order so a stale position is never reused. Called at the
  /// start of [connect]; also the seam tests use to exercise the
  /// cache-invalidation-on-order-change behaviour without a live STOMP client.
  @visibleForTesting
  void selectOrder(String orderId) {
    if (orderId != _currentOrderId) {
      _lastLocation = null;
      _currentOrderId = orderId;
    }
  }

  /// Parses a raw location frame [body], caches it as the last known rider
  /// position, and publishes it to [locationStream].
  ///
  /// Extracted from the STOMP subscription callback so the parse/cache/emit path
  /// is unit-testable without instantiating a real STOMP client.
  @visibleForTesting
  void handleLocationFrame(String? body) {
    if (body == null) return;
    try {
      final json = jsonDecode(body);
      final update = RiderLocationUpdate.fromJson(json);
      _lastLocation = update;
      _locationController.add(update);
    } catch (e) {
      debugPrint('Failed to parse location update: $e');
    }
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    // _lastLocation and _currentOrderId are intentionally retained here: a quick
    // navigate-away-and-back should be able to reseed the rider marker from the
    // last known position. They are cleared only when [connect] switches to a
    // different order (see [selectOrder]).
  }
}
