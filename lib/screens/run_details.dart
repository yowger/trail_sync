import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:trail_sync/models/run.dart';
import 'package:trail_sync/helpers/run_split.dart' as run_split;

class RunDetailScreen extends StatefulWidget {
  final Run run;

  const RunDetailScreen({super.key, required this.run});

  @override
  State<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends State<RunDetailScreen> {
  MapLibreMapController? mapController;

  @override
  Widget build(BuildContext context) {
    final splits = run_split.calculateSplits(widget.run.points);

    for (var s in splits) {
      print(
        "☺️🙂😊😀😁 Km ${s.kilometer}: "
        "${s.duration.inMinutes}:${(s.duration.inSeconds % 60).toString().padLeft(2, '0')} "
        "(${s.pace.toStringAsFixed(2)} min/km)",
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context),
      body: Column(
        children: [
          if (widget.run.points.isNotEmpty)
            SizedBox(
              height: 300,
              child: RunMap(
                run: widget.run,
                controllerSetter: (c) => mapController = c,
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RunStats(run: widget.run),
                    RunSplits(
                      splits: run_split.calculateSplits(widget.run.points),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

AppBar buildAppBar(BuildContext context) {
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

class RunMap extends StatefulWidget {
  final Run run;
  final void Function(MapLibreMapController) controllerSetter;

  const RunMap({super.key, required this.run, required this.controllerSetter});

  @override
  State<RunMap> createState() => _RunMapState();
}

class _RunMapState extends State<RunMap> {
  MapLibreMapController? _controller;
  Line? trailLine;

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

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
      trailLine = await _controller!.addLine(
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
    final now = DateTime.now();
    String formattedDate = '';
    String formattedTime = '';
    if (run.startTime != null) {
      final st = run.startTime!;
      if (st.year == now.year) {
        formattedDate = DateFormat('MMM d').format(st);
      } else {
        formattedDate = DateFormat('MMM d, yyyy').format(st);
      }
      formattedTime = DateFormat('h:mm a').format(st);
    }

    final distance = (run.distanceKm).toStringAsFixed(2);
    final duration = _formatDuration(Duration(seconds: run.durationSec ?? 0));
    final pace = run.avgPaceMinPerKm != null
        ? run.avgPaceMinPerKm!.toStringAsFixed(2)
        : "-";

    final dateStr = run.endTime != null
        ? "${run.endTime!.month}/${run.endTime!.day}/${run.endTime!.year}"
        : "-";
    final timeStr = run.endTime != null
        ? "${run.endTime!.hour}:${run.endTime!.minute.toString().padLeft(2, '0')}"
        : "-";

    return Card(
      color: Colors.white,
      elevation: 0.3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        getActivityIcon(run.mode),
                        size: 18,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      getActivityLabel(run.mode),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              run.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: StatItem(label: "Duration", value: duration),
                ),
                Expanded(
                  child: StatItem(
                    label: "Distance",
                    unit: "km",
                    value: distance,
                  ),
                ),
                Expanded(
                  child: StatItem(label: "Avg Pace", unit: "/km", value: pace),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (run.description.isNotEmpty) ...[
              const Text(
                "Description:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              ExpandableText(text: run.description),
            ],
          ],
        ),
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

class StatItem extends StatelessWidget {
  final String value;
  final String label;
  final String? unit;
  const StatItem({
    super.key,
    required this.value,
    required this.label,
    this.unit,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            if (unit != null) ...[
              const SizedBox(width: 2),
              Text(
                unit!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        Text(label, style: TextStyle(fontSize: 12.75, color: Colors.grey[600])),
      ],
    );
  }
}

String getActivityLabel(String type) {
  switch (type.toLowerCase()) {
    case "running":
      return "Run";
    case "cycling":
      return "Cycle";
    case "walking":
      return "Walk";
    default:
      return "Activity";
  }
}

IconData getActivityIcon(String activityType) {
  switch (activityType.toLowerCase()) {
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

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;

  const ExpandableText({super.key, required this.text, this.trimLines = 3});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  bool isOverflowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    final textSpan = TextSpan(
      text: widget.text,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    );
    final tp = TextPainter(
      text: textSpan,
      maxLines: widget.trimLines,
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout(maxWidth: context.size?.width ?? double.infinity);

    if (mounted) {
      setState(() {
        isOverflowing = tp.didExceedMaxLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = const TextStyle(fontSize: 14, color: Colors.black87);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: style,
          maxLines: isExpanded ? null : widget.trimLines,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (isOverflowing) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Text(
              isExpanded ? "Show less" : "Show more",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class RunSplits extends StatelessWidget {
  final List<run_split.Split> splits;

  const RunSplits({super.key, required this.splits});

  @override
  Widget build(BuildContext context) {
    if (splits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0.3,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Splits",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Column(
              children: splits.map((s) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Km ${s.kilometer}"),
                      Text(
                        "${s.duration.inMinutes}:${(s.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text("${s.pace.toStringAsFixed(2)} /km"),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
