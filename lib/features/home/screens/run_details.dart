import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:intl/intl.dart';
import 'package:trail_sync/features/home/widgets/activity_card.dart';
import 'package:trail_sync/features/home/widgets/run_splits.dart';
import 'package:trail_sync/helpers/run_format.dart';
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
    final pace = widget.run.avgPaceMinPerKm?.toStringAsFixed(2);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context),
      body: Stack(
        children: [
          if (widget.run.points.isNotEmpty)
            Positioned.fill(
              child: RunMap(
                run: widget.run,
                controllerSetter: (c) => mapController = c,
              ),
            ),

          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.15,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black26.withValues(alpha: 0.10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      ActivityCard(
                        activityName: widget.run.name,
                        description: widget.run.description,
                        username: widget.run.name,
                        userImageUrl: widget.run.user.imageUrl,
                        address: widget.run.address,
                        activityType: widget.run.mode,
                        distance: widget.run.distanceKm.toStringAsFixed(2),
                        duration: formatDuration(
                          Duration(seconds: widget.run.durationSec),
                        ),
                        pace: pace,
                        date: widget.run.startTime,
                        trailPoints: widget.run.points
                            .map((p) => LatLng(p.lat, p.lng))
                            .toList(),
                      ),

                      Divider(
                        color: Colors.grey[300],
                        thickness: 3,
                        indent: 0,
                        endIndent: 0,
                      ),

                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Splits",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      RunSplits(splits: splits),
                    ],
                  ),
                ),
              );
            },
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
        _fitBounds(bottomInsetFraction: 0.5);
      },
      onStyleLoadedCallback: () async {
        await _drawTrail();
      },
      styleString:
          "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
    );
  }

  void _fitBounds({double bottomInsetFraction = 0.0}) {
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

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = screenHeight * bottomInsetFraction;

    _controller?.moveCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        left: 16,
        top: 16,
        right: 16,
        bottom: 16 + bottomInset,
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
