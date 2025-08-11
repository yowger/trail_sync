import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trail_sync/providers/location_provider.dart';

class SingleActivityScreen extends ConsumerWidget {
  const SingleActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveLocation = ref.watch(locationStreamProvider);
    final mode = ref.watch(activityModeProvider);
    final isPaused = ref.watch(isPausedProvider);

    final service = ref.read(locationServiceProvider);

    void start(String m) {
      ref.read(activityModeProvider.notifier).state = m;
      service.startTracking(m);
    }

    void pause() {
      service.pauseTracking();
      ref.read(isPausedProvider.notifier).state = true;
    }

    void resume() {
      service.resumeTracking();
      ref.read(isPausedProvider.notifier).state = false;
    }

    void stop() {
      service.stopTracking();
      ref.read(activityModeProvider.notifier).state = null;
      ref.read(isPausedProvider.notifier).state = false;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Activity Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (liveLocation.hasValue)
              Text(
                "Lat: ${liveLocation.value!['lat']}, Lng: ${liveLocation.value!['lng']}",
                style: const TextStyle(fontSize: 18),
              )
            else
              const Text("Waiting for location..."),
            const SizedBox(height: 20),
            if (mode == null) ...[
              ElevatedButton(
                onPressed: () => start('running'),
                child: const Text("Start Running"),
              ),
              ElevatedButton(
                onPressed: () => start('cycling'),
                child: const Text("Start Cycling"),
              ),
              ElevatedButton(
                onPressed: () => start('walking'),
                child: const Text("Start Walking"),
              ),
            ] else ...[
              if (!isPaused)
                ElevatedButton(onPressed: pause, child: const Text("Pause"))
              else
                ElevatedButton(onPressed: resume, child: const Text("Resume")),
              ElevatedButton(onPressed: stop, child: const Text("Stop")),
            ],
          ],
        ),
      ),
    );
  }
}
