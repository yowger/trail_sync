import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:trail_sync/services/trackin_metrics_service.dart';
import 'package:trail_sync/providers/auth_provider.dart';
import 'package:trail_sync/providers/location_provider.dart';

String _formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final hours = twoDigits(d.inHours);
  final minutes = twoDigits(d.inMinutes.remainder(60));
  final seconds = twoDigits(d.inSeconds.remainder(60));
  return "$hours:$minutes:$seconds";
}

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
    final userId = ref.watch(authStateProvider).value?.uid;
    final service = ref.read(locationServiceProvider);

    final selectedMode = ref.watch(activityModeProvider) ?? "running";
    final isPaused = ref.watch(isPausedProvider);
    final isTracking = ref.watch(isTrackingProvider).value ?? false;

    final points = service.currentSession;
    final duration = ref.watch(movingTimeStreamProvider).value ?? Duration.zero;
    final trackingMetrics = TrackingMetricsService();
    final distanceMeters = trackingMetrics.calculateTotalDistance(points);
    final avgPace = trackingMetrics.calculateAveragePace(points, duration);

    final paceText = (avgPace != null && avgPace.isFinite)
        ? "${avgPace.toStringAsFixed(1)} min/km"
        : "--";

    final distanceKmText = (distanceMeters > 0)
        ? (distanceMeters / 1000).toStringAsFixed(2)
        : "0.00";

    void start(String mode) {
      ref.read(activityModeProvider.notifier).state = mode;
      service.startTracking(mode);
    }

    void pause() {
      service.pauseTracking();
      ref.read(isPausedProvider.notifier).state = true;
    }

    void resume() {
      service.resumeTracking();
      ref.read(isPausedProvider.notifier).state = false;
    }

    void stopTracking() {
      service.stopTracking();
      ref.read(activityModeProvider.notifier).state = null;
      ref.read(isPausedProvider.notifier).state = false;
    }

    void finish() {
      stopTracking();
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

    void saveActivity(String name, String description) async {
      if (userId == null) return;

      final start = service.startTime;
      final end = service.endTime ?? DateTime.now();
      final duration = end.difference(start ?? end);
      final distanceKm = trackingMetrics.calculateTotalDistance(points) / 1000;
      final avgPace = trackingMetrics.calculateAveragePace(points, duration);

      final runData = {
        'userId': userId,
        'name': name,
        'description': description,
        'startTime': start?.toIso8601String(),
        'endTime': end.toIso8601String(),
        'durationSec': duration.inSeconds,
        'distanceKm': distanceKm,
        'avgPaceMinPerKm': avgPace,
        'points': points.map((p) => p.toJson()).toList(),
      };

      try {
        final docRef = await FirebaseFirestore.instance
            .collection('runs')
            .add(runData);

        await docRef.update({'id': docRef.id});
        print('Run saved: ${docRef.id}');
      } catch (e) {
        print('Error saving run: $e');
      }

      stopTracking();
    }

    Future<void> showFinishDialog(BuildContext context) async {
      final save = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Finish Activity'),
          content: const Text('Do you want to save your activity?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Discard'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (save == true) {
        final result = await GoRouter.of(
          context,
        ).push<Map<String, String>>('/activity/save_run');

        if (result != null) {
          final runName = result['name'] ?? 'Unnamed run';
          final runDesc = result['description'] ?? '';
          // Save activity here with the runName and runDesc
          saveActivity(runName, runDesc);
        } else {
          // User canceled save screen, maybe just stop tracking anyway
          stopTracking();
        }
      } else {
        // User chose discard, just stop tracking
        stopTracking();
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
                          _statItem("Time", _formatDuration(duration)),
                          _statItem("Distance", distanceKmText),
                          _statItem("Pace", paceText),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: isPaused ? resume : pause,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: isPaused
                                  ? Colors.orange
                                  : Colors.amber,
                              child: Icon(
                                isPaused ? Icons.play_arrow : Icons.pause,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isPaused ? "Resume" : "Pause",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isPaused)
                        InkWell(
                          onTap: () => showFinishDialog(context),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.red,
                                child: const Icon(
                                  Icons.stop,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Finish",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
