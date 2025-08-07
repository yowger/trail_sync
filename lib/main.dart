import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trail_sync/screens/activity.dart';
import 'package:trail_sync/screens/home.dart';
import 'package:trail_sync/screens/profile.dart';
import 'package:trail_sync/screens/sign_in.dart';
import 'package:trail_sync/screens/sign_up.dart';
import 'package:trail_sync/widgets/tab.dart';
import 'package:trail_sync/theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/sign_in',
  routes: [
    GoRoute(
      name: 'sign_in',
      path: '/sign_in',
      builder: (_, __) => const SignInScreen(),
    ),
    GoRoute(
      name: 'sign_up',
      path: '/signup',
      builder: (_, __) => const SignUpScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return TabScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/activity',
              name: 'activity',
              builder: (context, state) => const ActivityScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (_, state) =>
      const Scaffold(body: Center(child: Text('Page not found'))),
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: AppTheme.lightTheme,
    );
  }
}
