import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:trail_sync/models/group_event_run.dart';

class EventDetailPage extends StatelessWidget {
  final GroupRunEvent event;

  const EventDetailPage({required this.event, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Description ---
          Text(event.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),

          // --- Mode & Distance ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Mode: ${event.mode}"),
              if (event.distanceTargetKm != null)
                Text("Distance: ${event.distanceTargetKm} km"),
            ],
          ),
          const SizedBox(height: 16),

          // --- Start Time ---
          Text(
            "Starts: ${event.startTime.toLocal()}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // --- Location ---
          if (event.location != null) ...[
            Text("Meeting Point: ${event.location!.address}"),
            SizedBox(
              height: 200,
              child: MapLibreMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(event.location!.lat, event.location!.lng),
                  zoom: 14,
                ),
                onMapCreated: (controller) async {
                  await controller.addSource(
                    "location_source",
                    GeojsonSourceProperties(
                      data: {
                        "type": "FeatureCollection",
                        "features": [
                          {
                            "type": "Feature",
                            "geometry": {
                              "type": "Point",
                              "coordinates": [
                                event.location!.lng,
                                event.location!.lat,
                              ],
                            },
                          },
                        ],
                      },
                    ),
                  );
                  await controller.addLayer(
                    "location_source",
                    "location_layer",
                    CircleLayerProperties(
                      circleColor: "#4285F4",
                      circleOpacity: 0.6,
                      circleRadius: 12,
                      circleStrokeColor: "#ffffff",
                      circleStrokeWidth: 2,
                    ),
                  );
                },
                styleString:
                    "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // --- Participants ---
          Text(
            "Participants (${event.participants.length}):",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...event.participants.map(
            (p) => ListTile(
              title: Text(p.userId),
              subtitle: Text("Status: ${p.status}"),
              trailing: Text(
                "Distance: ${p.currentDistanceKm.toStringAsFixed(2)} km",
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- Join Event Button ---
          ElevatedButton(
            onPressed: () {
              // TODO: implement joinEvent function from your service
            },
            child: const Text("Join Event"),
          ),
        ],
      ),
    );
  }
}
