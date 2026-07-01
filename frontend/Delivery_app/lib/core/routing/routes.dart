class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const history = '/history';
  static const earnings = '/earnings';
  static const profile = '/profile';
  static const notifications = '/notifications';
  static const settings = '/settings';
  
  static String assignment(String orderId) => '/assignment/$orderId';
  static String navigate(String orderId, String destination) => '/navigate/$orderId/$destination';
}
