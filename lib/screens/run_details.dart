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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          if (widget.run.points.isNotEmpty)
            SizedBox(
              height: 300,
              child: RunMap(
                run: widget.run,
                controllerSetter: (c) => _mapController = c,
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: RunStats(run: widget.run)),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Ink(
          decoration: const ShapeDecoration(
            color: Colors.black54,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

class RunMap extends StatefulWidget {
  final Run run;
  final void Function(MapLibreMapController) controllerSetter;

  const RunMap({super.key, required this.run, required this.controllerSetter});

  @override
  State<RunMap> createState() => _RunMapState();
}

class _RunMapState extends State<RunMap> {
  MapLibreMapController? _controller;
  Line? _trailLine;

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.run.points.first.lat,
          widget.run.points.first.lng,
        ),
        zoom: 8,
      ),
      onMapCreated: (controller) async {
        _controller = controller;
        widget.controllerSetter(controller);
        _fitBounds();
      },
      onStyleLoadedCallback: () async {
        await _drawTrail();
      },
      styleString:
          "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
    );
  }

  void _fitBounds() {
    final latitudes = widget.run.points.map((p) => p.lat).toList();
    final longitudes = widget.run.points.map((p) => p.lng).toList();

    double minLat = latitudes.reduce((a, b) => a < b ? a : b);
    double maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    double minLng = longitudes.reduce((a, b) => a < b ? a : b);
    double maxLng = longitudes.reduce((a, b) => a > b ? a : b);

    const margin = 0.0005;
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - margin, minLng - margin),
      northeast: LatLng(maxLat + margin, maxLng + margin),
    );

    _controller?.moveCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        left: 16,
        top: 16,
        right: 16,
        bottom: 16,
      ),
    );
  }

  Future<void> _drawTrail() async {
    if (_controller != null && widget.run.points.isNotEmpty) {
      _trailLine = await _controller!.addLine(
        LineOptions(
          geometry: widget.run.points.map((p) => LatLng(p.lat, p.lng)).toList(),
          lineColor: "#2563EB",
          lineWidth: 3,
          lineOpacity: 0.8,
          lineJoin: "round",
        ),
      );

      await _controller!.addSymbol(
        SymbolOptions(
          geometry: LatLng(
            widget.run.points.first.lat,
            widget.run.points.first.lng,
          ),
          iconImage: "marker-15",
          iconSize: 1.5,
          textField: "Start",
          textOffset: const Offset(0, 1.5),
        ),
      );

      await _controller!.addSymbol(
        SymbolOptions(
          geometry: LatLng(
            widget.run.points.last.lat,
            widget.run.points.last.lng,
          ),
          iconImage: "marker-15",
          iconSize: 1.5,
          textField: "End",
          textOffset: const Offset(0, 1.5),
        ),
      );
    }
  }
}

class RunStats extends StatelessWidget {
  final Run run;

  const RunStats({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final distance = "${(run.distanceKm ?? 0).toStringAsFixed(2)} km";
    final duration = _formatDuration(Duration(seconds: run.durationSec ?? 0));
    final pace = run.avgPaceMinPerKm != null
        ? "${run.avgPaceMinPerKm!.toStringAsFixed(2)} /km"
        : "-";

    final dateStr = run.endTime != null
        ? "${run.endTime!.month}/${run.endTime!.day}/${run.endTime!.year}"
        : "-";
    final timeStr = run.endTime != null
        ? "${run.endTime!.hour}:${run.endTime!.minute.toString().padLeft(2, '0')}"
        : "-";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                _getActivityIcon(run.mode),
                size: 18,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              run.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatItem(label: "Duration", value: duration),
            StatItem(label: "Distance", value: distance),
            StatItem(label: "Pace", value: pace),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            StatItem(label: "Date", value: dateStr),
            const SizedBox(width: 24),
            StatItem(label: "Time", value: timeStr),
          ],
        ),
        const SizedBox(height: 16),

        if ((run.description).isNotEmpty)
          Text(
            "Description: ${run.description}",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
      ],
    );
  }

  IconData _getActivityIcon(String? activityType) {
    switch (activityType?.toLowerCase()) {
      case "running":
        return Icons.directions_run;
      case "walking":
        return Icons.directions_walk;
      case "cycling":
      case "biking":
        return Icons.directions_bike;
      default:
        return Icons.fitness_center;
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final String value;

  const StatItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}
