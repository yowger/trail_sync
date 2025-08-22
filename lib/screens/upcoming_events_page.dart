import 'package:flutter/material.dart';
import 'package:trail_sync/models/group_event_run.dart';
import 'package:trail_sync/services/group_run_service.dart';
import 'package:intl/intl.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  _UpcomingEventsScreenState createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  final GroupRunService _service = GroupRunService();
  late Future<List<GroupRunEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _service.fetchUpcomingEvents();
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('MMM dd, yyyy – hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming Group Runs")),
      body: FutureBuilder<List<GroupRunEvent>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: InkWell(
                onTap: () => debugPrint("⚠️ Tapped error: ${snapshot.error}"),
                child: Text(
                  "Error fetching events: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(child: Text("No upcoming events"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  title: Text(
                    event.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(event.description),
                      const SizedBox(height: 4),
                      Text("Starts: ${_formatDateTime(event.startTime)}"),
                      if (event.location != null)
                        Text("Location: ${event.location!.address}"),
                      Text("Participants: ${event.participants.length}"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: navigate to event detail or map
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
