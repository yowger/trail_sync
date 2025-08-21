import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trail_sync/helpers/handle_locate_permissions.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;
  const MapPickerPage({this.initialLocation, super.key});

  @override
  _MapPickerPageState createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final Completer<MapLibreMapController> mapController = Completer();
  MapLibreMapController? _controller;

  late LatLng _selectedLocation;
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _addressController = TextEditingController();

  static const String _circleSourceId = "circle_source";
  static const String _circleLayerId = "circle_layer";

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation ?? const LatLng(28.6139, 77.2090);
    _updateControllers(_selectedLocation);
    if (widget.initialLocation != null) {
      _reverseGeocode(_selectedLocation);
    }
  }

  void _updateControllers(LatLng coords) {
    _latController.text = coords.latitude.toStringAsFixed(6);
    _lngController.text = coords.longitude.toStringAsFixed(6);
  }

  Future<void> _reverseGeocode(LatLng coords) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coords.latitude,
        coords.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _addressController.text =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        return;
      }
      _addressController.text = "Unknown address";
    } catch (_) {
      _addressController.text = "Unknown address";
    }
  }

  Future<void> _addCircle(LatLng coords) async {
    if (_controller == null) return;

    try {
      await _controller!.removeLayer(_circleLayerId);
      await _controller!.removeSource(_circleSourceId);
    } catch (_) {}

    await _controller!.addSource(
      _circleSourceId,
      GeojsonSourceProperties(
        data: {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [coords.longitude, coords.latitude],
              },
            },
          ],
        },
      ),
    );

    await _controller!.addLayer(
      _circleSourceId,
      _circleLayerId,
      CircleLayerProperties(
        circleColor: "#4285F4",
        circleOpacity: 0.4,
        circleRadius: 12,
        circleStrokeWidth: 2,
        circleStrokeColor: "#ffffff",
      ),
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController.complete(controller);
    _controller = controller;
    if (widget.initialLocation != null) {
      _addCircle(widget.initialLocation!);
    }
  }

  void _onMapTap(Point<double> point, LatLng coords) {
    setState(() {
      _selectedLocation = coords;
    });
    _updateControllers(coords);
    _reverseGeocode(coords);
    _addCircle(coords);
  }

  Future<void> _centerOnUser() async {
    bool granted = await handleLocationPermission();
    if (!granted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final coords = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = coords;
      });
      _updateControllers(coords);
      _reverseGeocode(coords);

      if (_controller != null) {
        await _controller!.animateCamera(CameraUpdate.newLatLng(coords));
        _addCircle(coords);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not get current location")),
      );
    }
  }

  void _onConfirm() {
    final coords = LatLng(
      double.tryParse(_latController.text) ?? _selectedLocation.latitude,
      double.tryParse(_lngController.text) ?? _selectedLocation.longitude,
    );
    final address = _addressController.text;

    Navigator.pop(context, {'coords': coords, 'address': address});
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MapLibreMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 14,
                  ),
                  onMapCreated: _onMapCreated,
                  onMapClick: _onMapTap,
                  styleString:
                      "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _centerOnUser,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _latController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Latitude",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lngController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Longitude",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onConfirm,
                    child: const Text("Finish", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TODO: design
