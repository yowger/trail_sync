import 'package:flutter/material.dart';
import 'package:trail_sync/models/group_event_run.dart';
import 'package:trail_sync/screens/create_event_run.dart';
import 'package:trail_sync/services/group_run_service.dart';
import 'package:trail_sync/widgets/events/event_cart.dart';
import 'package:trail_sync/widgets/ui/app_divider.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  bool showUpcoming = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          CreateEventHeader(),

          AppDivider(),

          EventList(showUpcoming: showUpcoming),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  child: const Text(
                    "See All Events",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class EventList extends StatelessWidget {
  final bool showUpcoming;
  final GroupRunService _service = GroupRunService();

  EventList({super.key, required this.showUpcoming});

  Future<List<GroupRunEvent>> _loadEvents() {
    return _service.fetchUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GroupRunEvent>>(
      future: _loadEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error loading events: ${snapshot.error}"));
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return Center(
            child: Text("No ${showUpcoming ? 'upcoming' : 'finished'} events"),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (_, __) => AppDivider(),
          itemBuilder: (context, index) => EventCard(event: events[index]),
        );
      },
    );
  }
}

class CreateEventHeader extends StatelessWidget {
  const CreateEventHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Create your own event", style: TextStyle(fontSize: 16)),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              textStyle: const TextStyle(fontSize: 14),
              side: const BorderSide(color: Colors.blue),
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final route = MaterialPageRoute(
                builder: (context) => CreateGroupRunScreen(),
              );
              Navigator.push(context, route);
            },
            child: const Text("Create a event"),
          ),
        ],
      ),
    );
  }
}
