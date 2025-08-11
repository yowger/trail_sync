import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:trail_sync/providers/location_provider.dart';

class SingleActivityScreen extends ConsumerStatefulWidget {
  const SingleActivityScreen({super.key});

  @override
  ConsumerState<SingleActivityScreen> createState() =>
      _SingleActivityScreenState();
}

class _SingleActivityScreenState extends ConsumerState<SingleActivityScreen> {
  final Completer<MapLibreMapController> mapController = Completer();

  @override
  Widget build(BuildContext context) {
    final liveLocation = ref.watch(locationStreamProvider);
    final mode = ref.watch(activityModeProvider);
    final isPaused = ref.watch(isPausedProvider);
    final service = ref.read(locationServiceProvider);
    final selectedMode = ref.watch(activityModeProvider) ?? "running";
    final isTrackingAsync = ref.watch(isTrackingProvider);
    final isTracking = isTrackingAsync.value ?? false;

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
      body: Column(
        children: [
          Expanded(
            child: MapLibreMap(
              onMapCreated: (controller) => mapController.complete(controller),
              initialCameraPosition: CameraPosition(
                target: LatLng(14.5995, 120.9842),
                zoom: 17,
              ),
              myLocationEnabled: true,
              styleString:
                  "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isTracking) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          final chosen = await showActivityModePicker(context);

                          if (chosen != null) {
                            ref.read(activityModeProvider.notifier).state =
                                chosen;
                          }
                        },
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.blueGrey,
                          child: Icon(
                            getActivityIcon(selectedMode),
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          start(selectedMode);
                        },
                        child: const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.play_arrow,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isPaused ? resume : pause,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: isPaused
                                ? Colors.orange
                                : Colors.amber,
                          ),
                          child: Text(
                            isPaused ? "Resume" : "Pause",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: stop,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            "Stop",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData getActivityIcon(String mode) {
  switch (mode) {
    case "running":
      return Icons.directions_run;
    case "cycling":
      return Icons.directions_bike;
    case "walking":
      return Icons.directions_walk;
    default:
      return Icons.help_outline; // fallback
  }
}

Future<String?> showActivityModePicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.directions_run),
            title: const Text("Run"),
            onTap: () => Navigator.pop(context, "running"),
          ),
          ListTile(
            leading: const Icon(Icons.directions_bike),
            title: const Text("Cycle"),
            onTap: () => Navigator.pop(context, "cycling"),
          ),
          ListTile(
            leading: const Icon(Icons.directions_walk),
            title: const Text("Walk"),
            onTap: () => Navigator.pop(context, "walking"),
          ),
        ],
      );
    },
  );
}
