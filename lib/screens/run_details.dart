import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:trail_sync/models/run.dart';

class RunDetailScreen extends StatefulWidget {
  final Run run;

  const RunDetailScreen({super.key, required this.run});

  @override
  State<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends State<RunDetailScreen> {
  MapLibreMapController? _mapController;
  Line? _trailLine;

  @override
  Widget build(BuildContext context) {
    final pace = widget.run.avgPaceMinPerKm != null
        ? "${widget.run.avgPaceMinPerKm!.toStringAsFixed(2)} min/km"
        : "-";
    final distance = "${(widget.run.distanceKm ?? 0).toStringAsFixed(2)} km";
    final duration = _formatDuration(
      Duration(seconds: widget.run.durationSec ?? 0),
    );
    final dateStr = widget.run.endTime != null
        ? "${widget.run.endTime!.month}/${widget.run.endTime!.day}/${widget.run.endTime!.year} "
              "${widget.run.endTime!.hour}:${widget.run.endTime!.minute.toString().padLeft(2, '0')}"
        : "-";

    return Scaffold(
      extendBodyBehindAppBar: true, // allow body to go behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // optional padding
          child: Ink(
            decoration: const ShapeDecoration(
              color: Colors.black54, // semi-transparent black
              shape: CircleBorder(),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (widget.run.points.isNotEmpty)
            SizedBox(
              height: 300,
              child: MapLibreMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.run.points.first.lat,
                    widget.run.points.first.lng,
                  ),
                  zoom: 8,
                ),
                onMapCreated: (controller) async {
                  _mapController = controller;

                  final latitudes = widget.run.points
                      .map((p) => p.lat)
                      .toList();
                  final longitudes = widget.run.points
                      .map((p) => p.lng)
                      .toList();

                  double minLat = latitudes.reduce((a, b) => a < b ? a : b);
                  double maxLat = latitudes.reduce((a, b) => a > b ? a : b);
                  double minLng = longitudes.reduce((a, b) => a < b ? a : b);
                  double maxLng = longitudes.reduce((a, b) => a > b ? a : b);

                  const margin = 0.00045;
                  final southwest = LatLng(minLat - margin, minLng - margin);
                  final northeast = LatLng(maxLat + margin, maxLng + margin);
                  final bounds = LatLngBounds(
                    southwest: southwest,
                    northeast: northeast,
                  );

                  controller.moveCamera(
                    CameraUpdate.newLatLngBounds(
                      bounds,
                      left: 16,
                      top: 16,
                      right: 16,
                      bottom: 16,
                    ),
                  );
                },
                onStyleLoadedCallback: () async {
                  if (_mapController != null && widget.run.points.isNotEmpty) {
                    _trailLine = await _mapController!.addLine(
                      LineOptions(
                        geometry: widget.run.points
                            .map((p) => LatLng(p.lat, p.lng))
                            .toList(),
                        lineColor: "#FF0000",
                        lineWidth: 3,
                        lineOpacity: 0.8,
                      ),
                    );

                    final startPoint = widget.run.points.first;
                    await _mapController!.addSymbol(
                      SymbolOptions(
                        geometry: LatLng(startPoint.lat, startPoint.lng),
                        iconImage: "marker-15",
                        iconSize: 1.5,
                        textField: "Start",
                        textOffset: const Offset(0, 1.5),
                      ),
                    );

                    final endPoint = widget.run.points.last;
                    await _mapController!.addSymbol(
                      SymbolOptions(
                        geometry: LatLng(endPoint.lat, endPoint.lng),
                        iconImage: "marker-15",
                        iconSize: 1.5,
                        textField: "End",
                        textOffset: const Offset(0, 1.5),
                      ),
                    );
                  }
                },
                styleString:
                    "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
              ),
            ),
          // Stats below
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.run.mode ?? "Activity",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Distance: ${(widget.run.distanceKm ?? 0).toStringAsFixed(2)} km",
                    ),
                    Text(
                      "Duration: ${_formatDuration(Duration(seconds: widget.run.durationSec ?? 0))}",
                    ),
                    Text(
                      "Pace: ${widget.run.avgPaceMinPerKm?.toStringAsFixed(2) ?? '-'} min/km",
                    ),
                    const SizedBox(height: 16),
                    Text("Description: ${widget.run.description ?? '-'}"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }
}
