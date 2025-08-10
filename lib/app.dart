// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:trail_sync/screens/home.dart';
// import 'package:trail_sync/screens/sign_up.dart';
// import 'package:trail_sync/widgets/auth_notifier.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authNotifier = AuthNotifier();

//     final router = GoRouter(
//       refreshListenable: authNotifier,
//       redirect: (context, state) {
//         final loggedIn = authNotifier.user != null;
//         final loggingIn = state.subloc == '/login';

//         if (!loggedIn && !loggingIn) {
//           return '/login';
//         }
//         if (loggedIn && loggingIn) {
//           return '/';
//         }
//         return null;
//       },
//       routes: [
//         GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
//         GoRoute(
//           path: '/login',
//           builder: (context, state) => const SignUpScreen(),
//         ),
//       ],
//     );

//     return ChangeNotifierProvider.value(
//       value: authNotifier,
//       child: MaterialApp.router(routerConfig: router),
//     );
//   }
// }
