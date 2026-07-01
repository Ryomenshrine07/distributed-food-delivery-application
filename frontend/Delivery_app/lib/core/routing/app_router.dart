import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/domain/repositories/session_repository.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/assignment/presentation/screens/assignment_detail_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/navigation/presentation/screens/navigation_screen.dart';
import '../../features/notifications/presentation/pages/notification_center_page.dart';
import '../widgets/placeholder_screen.dart';
import 'go_router_refresh_stream.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

String? appRedirect(BuildContext context, GoRouterState state, SessionRepository sessionRepo) {
  final session = sessionRepo.currentSession;
  final isAuth = session != null && !session.isExpired;

  final isSplash = state.uri.path == AppRoutes.splash;
  final isLogin = state.uri.path == AppRoutes.login;
  final isRegister = state.uri.path == AppRoutes.register;

  if (isSplash) {
    return isAuth ? AppRoutes.home : AppRoutes.login;
  }

  if (!isAuth) {
    if (!isLogin && !isRegister) {
      return AppRoutes.login;
    }
    return null;
  }

  if (isLogin || isRegister) {
    return AppRoutes.home;
  }

  return null;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(sessionRepo.sessionChanges),
    redirect: (context, state) => appRedirect(context, state, sessionRepo),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const PlaceholderScreen(title: 'Splash'),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(state.uri.path),
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go(AppRoutes.home);
                    break;
                  case 1:
                    context.go(AppRoutes.earnings);
                    break;
                  case 2:
                    context.go(AppRoutes.profile);
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Earnings'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.earnings,
            builder: (context, state) => const EarningsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationCenterPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
          ),
          GoRoute(
            path: '/assignment/:orderId',
            builder: (context, state) => AssignmentDetailScreen(
              orderId: state.pathParameters['orderId']!,
            ),
          ),
          GoRoute(
            path: '/navigate/:orderId/:destination',
            builder: (context, state) => NavigationScreen(
              orderId: state.pathParameters['orderId']!,
              destination: state.pathParameters['destination']!,
            ),
          ),
        ],
      ),
    ],
  );
});

int _calculateSelectedIndex(String path) {
  if (path.startsWith(AppRoutes.home)) return 0;
  if (path.startsWith(AppRoutes.earnings)) return 1;
  if (path.startsWith(AppRoutes.profile)) return 2;
  return 0;
}
