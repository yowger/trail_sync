import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class ActivityMiniMap extends StatefulWidget {
  final List<LatLng> points;
  final double width;
  final double height;

  const ActivityMiniMap({
    super.key,
    required this.points,
    this.width = double.infinity,
    this.height = 150,
  });

  @override
  State<ActivityMiniMap> createState() => _ActivityMiniMapState();
}

class _ActivityMiniMapState extends State<ActivityMiniMap> {
  MapLibreMapController? _mapController;
  Line? _trailLine;

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(child: Text("No map data")),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: MapLibreMap(
        initialCameraPosition: CameraPosition(
          target: widget.points.first,
          zoom: 12,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          _fitBounds();
        },
        onStyleLoadedCallback: () async {
          if (_mapController != null) {
            _trailLine = await _mapController!.addLine(
              LineOptions(
                geometry: widget.points,
                lineColor: "#FF0000",
                lineWidth: 2,
                lineOpacity: 0.8,
              ),
            );

            await _mapController!.addSymbol(
              SymbolOptions(
                geometry: widget.points.first,
                iconImage: "marker-15",
                iconSize: 1.2,
              ),
            );
            await _mapController!.addSymbol(
              SymbolOptions(
                geometry: widget.points.last,
                iconImage: "marker-15",
                iconSize: 1.2,
              ),
            );
          }
        },
        styleString:
            "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
        rotateGesturesEnabled: false,
        scrollGesturesEnabled: false,
        tiltGesturesEnabled: false,
        zoomGesturesEnabled: false,
      ),
    );
  }

  void _fitBounds() {
    if (_mapController == null || widget.points.isEmpty) return;

    final latitudes = widget.points.map((p) => p.latitude).toList();
    final longitudes = widget.points.map((p) => p.longitude).toList();

    final southwest = LatLng(
      latitudes.reduce((a, b) => a < b ? a : b),
      longitudes.reduce((a, b) => a < b ? a : b),
    );
    final northeast = LatLng(
      latitudes.reduce((a, b) => a > b ? a : b),
      longitudes.reduce((a, b) => a > b ? a : b),
    );

    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);

    _mapController!.moveCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        left: 8,
        top: 8,
        right: 8,
        bottom: 8,
      ),
    );
  }
}
