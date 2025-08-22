import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:trail_sync/models/group_event_run.dart';

class EventDetailScreen extends StatefulWidget {
  final GroupRunEvent event;

  const EventDetailScreen({required this.event, super.key});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  MapLibreMapController? mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Description ---
          Text(widget.event.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),

          // --- Mode & Distance ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Mode: ${widget.event.mode}"),
              if (widget.event.distanceTargetKm != null)
                Text("Distance: ${widget.event.distanceTargetKm} km"),
            ],
          ),
          const SizedBox(height: 16),

          // --- Start Time ---
          Text(
            "Starts: ${widget.event.startTime.toLocal()}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // --- Location ---
          if (widget.event.location != null) ...[
            Text("Meeting Point: ${widget.event.location!.address}"),
            SizedBox(
              height: 200,
              child: MapLibreMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.event.location!.lat,
                    widget.event.location!.lng,
                  ),
                  zoom: 14,
                ),
                onMapCreated: (controller) async {
                  mapController = controller; // store globally in state
                },
                onStyleLoadedCallback: () async {
                  await mapController!.addSource(
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
                                widget.event.location!.lng,
                                widget.event.location!.lat,
                              ],
                            },
                          },
                        ],
                      },
                    ),
                  );
                  await mapController!.addLayer(
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
            "Participants (${widget.event.participants.length}):",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.event.participants.map(
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
              // You can now access `mapController` here if needed
            },
            child: const Text("Join Event"),
          ),
        ],
      ),
    );
  }
}
