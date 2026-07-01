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

  Stream<RiderLocationUpdate> get locationStream => _locationController.stream;

  void connect(String orderId, {String? token}) {
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
            callback: (StompFrame frame) {
              if (frame.body != null) {
                try {
                  final json = jsonDecode(frame.body!);
                  final update = RiderLocationUpdate.fromJson(json);
                  _locationController.add(update);
                } catch (e) {
                  debugPrint('Failed to parse location update: $e');
                }
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => debugPrint('WebSocket Error: $error'),
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
      ),
    );

    _stompClient?.activate();
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }
}
