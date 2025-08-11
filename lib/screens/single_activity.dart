import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trail_sync/providers/location_provider.dart';

class SingleActivityScreen extends ConsumerWidget {
  const SingleActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveLocation = ref.watch(locationStreamProvider);
    final mode = ref.watch(activityModeProvider);

    void startActivity(String mode) {
      final service = ref.read(locationServiceProvider);
      ref.read(activityModeProvider.notifier).state = mode;
      service.startTracking(mode);
    }

    void stopActivity() {
      final service = ref.read(locationServiceProvider);
      ref.read(activityModeProvider.notifier).state = null;
      service.stopTracking();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Activity Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (liveLocation.hasValue) ...[
              Text(
                "Lat: ${liveLocation.value!['lat']}, Lng: ${liveLocation.value!['lng']}",
                style: const TextStyle(fontSize: 18),
              ),
              Text("Mode: ${mode ?? 'none'}"),
            ] else
              const Text("Waiting for location..."),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => startActivity('running'),
              child: const Text("Start Running"),
            ),
            ElevatedButton(
              onPressed: () => startActivity('cycling'),
              child: const Text("Start Cycling"),
            ),
            ElevatedButton(
              onPressed: () => startActivity('walking'),
              child: const Text("Start Walking"),
            ),
            ElevatedButton(onPressed: stopActivity, child: const Text("Stop")),
          ],
        ),
      ),
    );
  }
}
