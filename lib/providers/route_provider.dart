import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:trail_sync/providers/auth_provider.dart';
import 'package:trail_sync/screens/create_event_run.dart';
import 'package:trail_sync/screens/home.dart';
import 'package:trail_sync/screens/save_run.dart';
import 'package:trail_sync/screens/sign_in.dart';
import 'package:trail_sync/screens/activity.dart';
import 'package:trail_sync/screens/groups.dart';
import 'package:trail_sync/screens/profile.dart';
import 'package:trail_sync/screens/sign_up.dart';
import 'package:trail_sync/screens/single_activity.dart';
import 'package:trail_sync/screens/upcoming_events_page.dart';
import 'package:trail_sync/widgets/tab.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/sign_in',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(firebaseAuthProvider).authStateChanges(),
    ),
    redirect: (context, state) {
      final user = authState.value;
      final isSigningIn = state.uri.path == '/sign_in';
      final isSigningUp = state.uri.path == '/sign_up';

      final goingTo = state.uri.toString();

      if (user == null) {
        print("user is null, going to: $goingTo");

        if (isSigningIn || isSigningUp) return null;

        return '/sign_in';
      }

      if (isSigningIn || isSigningUp) {
        print("user is set, going to: $goingTo");

        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        name: 'sign_in',
        path: '/sign_in',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        name: 'sign_up',
        path: '/sign_up',
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/activity/save_run',
        name: 'save_run',
        builder: (context, state) {
          return const SaveRunScreen();
        },
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
                // builder: (context, state) => const ActivityScreen(),
                // builder: (context, state) => const SingleActivityScreen(),
                builder: (context, state) => const SingleActivityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/groups',
                name: 'groups',
                // builder: (context, state) => const GroupsScreen(),
                // builder: (context, state) => const CreateGroupRunScreen(),
                builder: (context, state) => const UpcomingEventsScreen(),
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
    errorBuilder: (_, state) {
      print("Unknown route: ${state.uri}");

      return const Scaffold(body: Center(child: Text('Page not found')));
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
