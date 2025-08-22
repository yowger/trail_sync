import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:trail_sync/models/group_event_run.dart';
import 'package:trail_sync/providers/auth_provider.dart';
import 'package:trail_sync/screens/map_picker.dart';
import 'package:trail_sync/services/group_run_service.dart';

class CreateGroupRunScreen extends ConsumerStatefulWidget {
  const CreateGroupRunScreen({super.key});

  @override
  ConsumerState<CreateGroupRunScreen> createState() =>
      _CreateGroupRunPageState();
}

class _CreateGroupRunPageState extends ConsumerState<CreateGroupRunScreen> {
  MapLibreMapController? _mapController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedRouteId;
  LatLng? _meetingLocation;
  String? _meetingAddress;

  String _mode = "running";
  DateTime? _startTime;

  Future<void> _createEvent() async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    if (_formKey.currentState!.validate()) {
      final service = GroupRunService();

      final newEvent = GroupRunEvent(
        id: FirebaseFirestore.instance.collection("events").doc().id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        createdBy: userId,
        startTime: _startTime ?? DateTime.now(),
        status: "scheduled",
        mode: _mode,
        distanceTargetKm: null,
        location: _meetingLocation != null
            ? EventLocation(
                lat: _meetingLocation!.latitude,
                lng: _meetingLocation!.longitude,
                address: _meetingAddress ?? "",
              )
            : null,
        participants: [
          // Participant(
          //   userId: userId,
          //   status: "ready",
          //   joinedAt: DateTime.now(),
          // ),
        ],
        visibility: "public",
        createdAt: DateTime.now(),
      );

      await service.createEvent(newEvent);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Group run created!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group Run")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(
                height: 200,
                child: _meetingLocation == null
                    ? const Center(child: Text("No meeting location selected"))
                    : MapLibreMap(
                        initialCameraPosition: CameraPosition(
                          target: _meetingLocation!,
                          zoom: 14,
                        ),
                        onMapCreated: (controller) async {
                          _mapController = controller;
                        },
                        onStyleLoadedCallback: () async {
                          await _mapController!.addSource(
                            "meeting_source",
                            GeojsonSourceProperties(
                              data: {
                                "type": "FeatureCollection",
                                "features": [
                                  {
                                    "type": "Feature",
                                    "geometry": {
                                      "type": "Point",
                                      "coordinates": [
                                        _meetingLocation!.longitude,
                                        _meetingLocation!.latitude,
                                      ],
                                    },
                                  },
                                ],
                              },
                            ),
                          );
                          await _mapController!.addLayer(
                            "meeting_source",
                            "meeting_layer",
                            CircleLayerProperties(
                              circleColor: "#4285F4",
                              circleOpacity: 0.4,
                              circleRadius: 12,
                              circleStrokeColor: "#ffffff",
                              circleStrokeWidth: 2,
                            ),
                          );
                        },
                        myLocationEnabled: false,
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        styleString:
                            "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
                      ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Event Name",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter a name" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _mode,
                items: const [
                  DropdownMenuItem(value: "running", child: Text("Running")),
                  DropdownMenuItem(value: "cycling", child: Text("Cycling")),
                  DropdownMenuItem(value: "walking", child: Text("Walking")),
                ],
                onChanged: (val) => setState(() => _mode = val!),
                decoration: const InputDecoration(
                  labelText: "Activity Type",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _meetingAddress,
                decoration: const InputDecoration(
                  labelText: "Meeting Address",
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => _meetingAddress = val,
              ),

              ListTile(
                title: Text(
                  _startTime == null
                      ? "Pick Start Time (optional)"
                      : "Starts: ${_startTime.toString()}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _startTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // --- Pick Route Button ---
              ElevatedButton.icon(
                onPressed: () async {
                  // Navigate to Route Builder / Picker page
                  const selectedRoute = null; // replace with navigation result
                  if (selectedRoute != null) {
                    setState(() {
                      _selectedRouteId = selectedRoute;
                    });
                  }
                },
                icon: const Icon(Icons.map),
                label: Text(
                  _selectedRouteId == null
                      ? "Pick Route (optional)"
                      : "Route Selected",
                ),
              ),
              const SizedBox(height: 16),

              // --- Pick Meeting Location ---
              ElevatedButton.icon(
                onPressed: () async {
                  final pickedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapPickerPage(),
                    ),
                  );
                  if (pickedLocation != null) {
                    final coords = pickedLocation['coords'] as LatLng;
                    final address = pickedLocation['address'] as String;

                    setState(() {
                      _meetingLocation = coords;
                      _meetingAddress = address;
                    });
                  }
                },
                icon: const Icon(Icons.place),
                label: Text(
                  _meetingLocation == null
                      ? "Pick Meeting Location"
                      : "Meeting Location Selected",
                ),
              ),
              const SizedBox(height: 24),

              // --- Create Button ---
              ElevatedButton(
                onPressed: _createEvent,
                child: const Text("Create Group Run"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
