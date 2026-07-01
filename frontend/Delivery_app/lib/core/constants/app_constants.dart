class AppConstants {
  static  String baseUrl = 'https://unlovable-unpopular-taste.ngrok-free.dev';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const int maxRetries = 3;

  // Location
  static const Duration heartbeatIntervalNormal = Duration(seconds: 10);
  static const Duration heartbeatIntervalLowBattery = Duration(seconds: 30);
  static const double distanceFilterMeters = 15.0; // 15m
}
