import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:trail_sync/features/map/widgets/circular_marker_image.dart';

import 'package:trail_sync/models/run.dart';

Future<Uint8List> loadMarkerImage(String path) async {
  var byteData = await rootBundle.load(path);
  return byteData.buffer.asUint8List();
}

class MapDetails extends StatefulWidget {
  final Run run;
  final void Function(MapLibreMapController) controllerSetter;

  const MapDetails({
    super.key,
    required this.run,
    required this.controllerSetter,
  });

  @override
  State<MapDetails> createState() => _MapDetailsState();
}

class _MapDetailsState extends State<MapDetails> {
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
      final Uint8List markerImage = await loadMarkerImage(
        'assets/images/google.png',
      );
      await _controller!.addImage('start-marker', markerImage);

      final Uint8List endMarkerImage = await createCircularMarkerWithImage(
        'assets/images/checkers.png',
        size: 40,
      );
      await _controller!.addImage('end-marker', endMarkerImage);

      await _controller!.addLine(
        LineOptions(
          geometry: widget.run.points.map((p) => LatLng(p.lat, p.lng)).toList(),
          lineColor: "#ffffff",
          lineWidth: 22,
          lineJoin: "round",
          lineBlur: 0.5,
        ),
      );

      await _controller!.addLine(
        LineOptions(
          geometry: widget.run.points.map((p) => LatLng(p.lat, p.lng)).toList(),
          lineColor: "#2563EB",
          lineWidth: 12,
          lineOpacity: 0.9,
          lineJoin: "round",
          lineBlur: 0.5,
        ),
      );

      await _controller!.addCircle(
        CircleOptions(
          geometry: LatLng(
            widget.run.points.first.lat,
            widget.run.points.first.lng,
          ),
          circleRadius: 10,
          circleColor: "#4caf50",
          circleStrokeColor: "#FFFFFF",
          circleStrokeWidth: 2,
        ),
      );

      await _controller!.addSymbol(
        SymbolOptions(
          geometry: LatLng(
            widget.run.points.last.lat,
            widget.run.points.last.lng,
          ),
          iconImage: "end-marker",
          iconSize: 1.5,
          iconAnchor: "bottom",
        ),
      );
    }
  }
}
