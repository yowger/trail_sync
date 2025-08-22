import 'package:flutter/material.dart';

import 'package:trail_sync/models/group_event_run.dart';
import 'package:trail_sync/screens/create_event_run.dart';
import 'package:trail_sync/services/group_run_service.dart';
import 'package:trail_sync/widgets/events/event_cart.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Event',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateGroupRunScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<GroupRunEvent>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: InkWell(
                onTap: () => setState(() {
                  _eventsFuture = _service.fetchUpcomingEvents();
                }),
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
            itemBuilder: (context, index) => EventCard(event: events[index]),
          );
        },
      ),
    );
  }
}
