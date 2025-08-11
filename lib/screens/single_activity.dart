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
  MapLibreMapController? _controller;

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

    Future<void> moveToCurrentLocation() async {
      final location = await service.getCurrentLocation();

      if (location != null && _controller != null) {
        _controller!.moveCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.coords.latitude, location.coords.longitude),
            16,
          ),
        );
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MapLibreMap(
                  onMapCreated: (controller) {
                    mapController.complete(controller);
                    _controller = controller;
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(14.5995, 120.9842),
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  styleString:
                      "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
                ),

                Positioned(
                  bottom: 95,
                  right: 16,
                  child: Column(
                    children: [
                      // _mapControlButton(Icons.add, () {
                      //   // Zoom in placeholder
                      // }),
                      const SizedBox(height: 8),
                      _mapControlButton(Icons.explore, () {}),
                      const SizedBox(height: 8),
                      _mapControlButton(Icons.my_location, () async {
                        await moveToCurrentLocation();
                      }),
                    ],
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 15,
                      left: 16,
                      right: 16,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem("Time", "00:32:10"),
                          _statItem("Distance", "5.3 km"),
                          _statItem("Speed", "10.2 km/h"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isTracking) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () async {
                          final chosen = await showActivityModePicker(context);
                          if (chosen != null) {
                            ref.read(activityModeProvider.notifier).state =
                                chosen;
                          }
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.25),
                              child: Icon(
                                getActivityIcon(selectedMode),
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              getModeLabel(selectedMode),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () => start(selectedMode),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: const Icon(
                                Icons.play_arrow,
                                size: 45,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text("Start", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.25),
                              child: Icon(
                                Icons.polyline,
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Add Route",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
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

Widget _mapControlButton(IconData icon, VoidCallback onTap) {
  return Material(
    color: Colors.white,
    shape: const CircleBorder(),
    elevation: 2,
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: Colors.black87),
      ),
    ),
  );
}

Widget _statItem(String label, String value) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}

IconData getActivityIcon(String mode) {
  switch (mode) {
    case "running":
      return Icons.directions_run_outlined;
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

String getModeLabel(String mode) {
  switch (mode) {
    case 'running':
      return 'Run';
    case 'walking':
      return 'Walk';
    case 'cycling':
      return 'Cycle';
    default:
      return mode;
  }
}
