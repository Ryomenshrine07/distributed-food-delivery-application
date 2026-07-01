import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/features/location/utils/heartbeat_throttle.dart';

void main() {
  group('HeartbeatThrottle', () {
    late HeartbeatThrottle throttle;

    setUp(() {
      throttle = HeartbeatThrottle(thresholdMeters: 15.0);
    });

    test('should return true on first heartbeat', () {
      expect(throttle.shouldSendHeartbeat(12.9716, 77.5946), isTrue);
    });

    test('should return false if moved less than threshold', () {
      throttle.onHeartbeatSent(12.9716, 77.5946);
      
      // Move a tiny bit (less than 15 meters)
      // 1 degree of latitude is ~111km. 15m is ~0.000135 degrees.
      // We will move by 0.00005 degrees (approx 5.5 meters).
      expect(throttle.shouldSendHeartbeat(12.97165, 77.5946), isFalse);
    });

    test('should return true if moved more than threshold', () {
      throttle.onHeartbeatSent(12.9716, 77.5946);
      
      // Move by 0.0002 degrees (approx 22 meters)
      expect(throttle.shouldSendHeartbeat(12.9718, 77.5946), isTrue);
    });

    test('should update last coordinates onHeartbeatSent', () {
      throttle.onHeartbeatSent(12.9716, 77.5946);
      expect(throttle.shouldSendHeartbeat(12.97165, 77.5946), isFalse);
      
      throttle.onHeartbeatSent(12.9718, 77.5946); // sent from a new location >15m away
      // Next heartbeat at the same new location should be false
      expect(throttle.shouldSendHeartbeat(12.9718, 77.5946), isFalse);
    });

    test('should return true after reset', () {
      throttle.onHeartbeatSent(12.9716, 77.5946);
      throttle.reset();
      expect(throttle.shouldSendHeartbeat(12.9716, 77.5946), isTrue);
    });
  });
}
