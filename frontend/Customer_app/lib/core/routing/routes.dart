/// Route path and name constants for the Customer App.
///
/// Using constants avoids typo-prone string literals throughout the codebase
/// and serves as the single source of truth for all route definitions.
class AppRoutes {
  AppRoutes._();

  // ---------- Paths ----------

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Protected (shell) routes
  static const String home = '/home';
  static const String search = '/search';
  static const String restaurant = '/restaurant/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String tracking = '/tracking/:orderId';
  static const String profile = '/profile';
  static const String addresses = '/addresses';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // ---------- Helpers ----------

  /// Builds the restaurant detail path for a given [id].
  static String restaurantPath(String id) => '/restaurant/$id';

  /// Builds the tracking path for a given [orderId].
  static String trackingPath(String orderId) => '/tracking/$orderId';

  /// Public routes that do not require authentication.
  static const Set<String> publicPaths = {
    splash,
    login,
    register,
    forgotPassword,
  };

  /// Whether the given [path] is a public (non-authenticated) route.
  static bool isPublic(String path) =>
      publicPaths.any((p) => path.startsWith(p));
}
