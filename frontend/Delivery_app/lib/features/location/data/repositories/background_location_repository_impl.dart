import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../domain/repositories/background_location_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../services/background_location_service.dart';

class BackgroundLocationRepositoryImpl implements BackgroundLocationRepository {
  BackgroundLocationRepositoryImpl(this._locationRepository);

  final LocationRepository _locationRepository;

  bool _receiverRegistered = false;

  @override
  void init() {
    BackgroundLocationService.init();
  }

  @override
  Future<void> startService() async {
    // Listen for GPS samples emitted by the background task isolate before the
    // service starts producing them.
    _registerReceiver();
    await BackgroundLocationService.startService();
  }

  @override
  Future<void> stopService() async {
    _unregisterReceiver();
    await BackgroundLocationService.stopService();
  }

  void _registerReceiver() {
    if (_receiverRegistered) return;
    FlutterForegroundTask.addTaskDataCallback(_onReceiveLocation);
    _receiverRegistered = true;
  }

  void _unregisterReceiver() {
    if (!_receiverRegistered) return;
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveLocation);
    _receiverRegistered = false;
  }

  /// Receives `<lat>,<lng>` payloads pushed from [LocationTaskHandler] via
  /// `sendDataToMain` and forwards them to the backend heartbeat endpoint so
  /// the customer's tracking screen can render the rider's live position.
  void _onReceiveLocation(Object data) {
    if (data is! String) return;
    if (data.startsWith('ERROR')) {
      debugPrint('Background location error: $data');
      return;
    }

    final parts = data.split(',');
    if (parts.length != 2) return;

    final latitude = double.tryParse(parts[0].trim());
    final longitude = double.tryParse(parts[1].trim());
    if (latitude == null || longitude == null) return;

    // Fire-and-forget: submitHeartbeat validates the session and coordinates
    // and swallows transient network errors internally.
    _locationRepository.submitHeartbeat(latitude, longitude);
  }
}
