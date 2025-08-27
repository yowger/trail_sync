import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trail_sync/features/home/widgets/home_content.dart';
import 'package:trail_sync/features/home/widgets/user_app_bar.dart';
import 'package:trail_sync/providers/auth_provider.dart';
import 'package:trail_sync/providers/run_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentRunsAsync = ref.watch(recentRunsProvider);
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: UserAppBar(userAsync: userAsync),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[300], height: 1),
        ),
      ),
      body: SafeArea(
        child: recentRunsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) {
            debugPrint('😮😮😮😮😮 Error loading runs: $e');
            debugPrintStack(stackTrace: st);
            return const Center(child: Text("Error loading runs"));
          },
          data: (runs) {
            if (runs.isEmpty) return const Center(child: Text("No runs yet"));

            return HomeContent(runs: runs, userAsync: userAsync);
          },
        ),
      ),
    );
  }
}
