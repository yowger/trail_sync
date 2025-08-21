import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:trail_sync/providers/auth_provider.dart';

class CreateGroupRunScreen extends ConsumerStatefulWidget {
  const CreateGroupRunScreen({super.key});

  @override
  ConsumerState<CreateGroupRunScreen> createState() =>
      _CreateGroupRunPageState();
}

class _CreateGroupRunPageState extends ConsumerState<CreateGroupRunScreen> {
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
      final docRef = FirebaseFirestore.instance.collection("events").doc();

      await docRef.set({
        "id": docRef.id,
        "createdBy": userId,
        "name": _nameController.text.trim(),
        "description": _descriptionController.text.trim(),
        "mode": _mode,
        "startTime": (_startTime ?? DateTime.now()).toIso8601String(),
        "status": "scheduled",
        "routeId": _selectedRouteId,
        "meetingLocation": _meetingLocation != null
            ? {
                "lat": _meetingLocation!.latitude,
                "lng": _meetingLocation!.longitude,
                "address": _meetingAddress ?? "",
              }
            : null,
        "participants": [
          {
            "userId": userId,
            "status": "joined",
            "joinedAt": DateTime.now().toIso8601String(),
          },
        ],
        "createdAt": DateTime.now().toIso8601String(),
      });

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
              // --- Map Preview ---
              SizedBox(
                height: 200,
                // child: _selectedRouteId == null
                //     ? Center(child: Text("No route selected"))
                //     : MapPreview(routeId: _selectedRouteId!),
              ),
              const SizedBox(height: 16),

              // --- Event Name ---
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

              // --- Description ---
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // --- Mode Dropdown ---
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

              // --- Start Time Picker ---
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
                  // final pickedLocation = await Navigator.push<LatLng>(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => const MeetingLocationPickerPage(),
                  //   ),
                  // );
                  final pickedLocation = null;
                  if (pickedLocation != null) {
                    setState(() {
                      _meetingLocation = pickedLocation;
                      _meetingAddress =
                          "Pinned location"; // optionally reverse-geocode
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
