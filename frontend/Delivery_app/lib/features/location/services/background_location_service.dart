
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Initialization code
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).then((position) {
      // Handle the new position (e.g., send via HTTP or sendPort)
      FlutterForegroundTask.sendDataToMain('${position.latitude},${position.longitude}');
    }).catchError((e) {
      FlutterForegroundTask.sendDataToMain('ERROR:$e');
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isDestroyed) async {
    // Cleanup code
  }

  @override
  void onReceiveData(Object data) {
    // Receive data from the UI isolate if necessary
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification button presses
  }
  
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}

class BackgroundLocationService {
  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'delivery_app_location',
        channelName: 'Foreground Service Notification',
        channelDescription: 'This notification appears when the background location service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(10000), // 10 seconds heartbeat
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }
    await FlutterForegroundTask.startService(
      notificationTitle: 'Delivery App',
      notificationText: 'Tracking your location for deliveries...',
      callback: startCallback,
    );
  }

  static Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }
}
