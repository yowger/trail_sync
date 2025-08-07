import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trail_sync/screens/sign_in.dart';
import 'package:trail_sync/screens/sign_up.dart';
import 'package:trail_sync/theme/app_theme.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      name: 'sign_in',
      path: '/',
      builder: (_, __) => const SignInScreen(),
    ),
    GoRoute(
      name: 'sign_up',
      path: '/signup',
      builder: (_, __) => const SignUpScreen(),
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
