import 'package:flutter/material.dart';
import 'package:trail_sync/models/group_event_run.dart';
import 'package:intl/intl.dart';
import 'package:trail_sync/screens/group_event_detail.dart';

class EventCard extends StatelessWidget {
  final GroupRunEvent event;

  const EventCard({super.key, required this.event});

  String _formatDateTime(DateTime dt) {
    return DateFormat('MMM dd, yyyy – hh:mm a').format(dt);
  }

  IconData _getEventIcon(String type) {
    switch (type.toLowerCase()) {
      case "running":
        return Icons.directions_run;
      case "walking":
        return Icons.directions_walk;
      case "cycling":
      case "biking":
        return Icons.directions_bike;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade100,
          child: Icon(_getEventIcon(event.mode), color: Colors.blue.shade700),
        ),
        title: Text(
          event.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (event.description.isNotEmpty)
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(event.startTime),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (event.location != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    event.location!.address,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              "Participants: ${event.participants.length}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
          );
        },
      ),
    );
  }
}
