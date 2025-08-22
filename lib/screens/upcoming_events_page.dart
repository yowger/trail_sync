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
  bool showUpcoming = true;
  late Future<List<GroupRunEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    _eventsFuture = showUpcoming
        ? _service.fetchUpcomingEvents()
        // : _service.fetchPastEvents(); // implement fetchPastEvents
        : _service.fetchUpcomingEvents();
    setState(() {});
  }

  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                showUpcoming = true;
                _loadEvents();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: showUpcoming ? Colors.blue : Colors.grey[300],
            ),
            child: Text(
              "Upcoming",
              style: TextStyle(
                color: showUpcoming ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showUpcoming = false;
                _loadEvents();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: !showUpcoming ? Colors.blue : Colors.grey[300],
            ),
            child: Text(
              "Finished",
              style: TextStyle(
                color: !showUpcoming ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupRunScreen()),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Create Event"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events")),
      body: Column(
        children: [
          _buildFilterButtons(),
          Expanded(
            child: FutureBuilder<List<GroupRunEvent>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading events: ${snapshot.error}"),
                  );
                }

                final events = snapshot.data ?? [];

                if (events.isEmpty) {
                  return Center(
                    child: Text(
                      "No ${showUpcoming ? 'upcoming' : 'finished'} events",
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      EventCard(event: events[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
