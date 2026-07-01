/// Application-wide constants for the Customer App.
class AppConstants {
  AppConstants._();

  /// Base URL for the API Gateway.
  static  String baseUrl = 'https://unlovable-unpopular-taste.ngrok-free.dev';
  
  /// Default page size for paginated requests.
  static const int defaultPageSize = 10;

  /// Connection timeout duration.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Receive timeout duration.
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Send timeout duration.
  static const Duration sendTimeout = Duration(seconds: 15);

  /// Debounce duration for search inputs.
  static const Duration debounceDuration = Duration(milliseconds: 500);

  /// Polling interval for order tracking.
  static const Duration pollingInterval = Duration(seconds: 10);

  /// Animation duration for transitions.
  static const Duration animationDuration = Duration(milliseconds: 300);
}
