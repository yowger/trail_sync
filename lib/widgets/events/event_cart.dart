import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:trail_sync/features/home/widgets/route_map_preview.dart';
import 'package:trail_sync/models/group_event_run.dart';
import 'package:trail_sync/screens/group_event_detail.dart';

class EventCard extends StatelessWidget {
  final GroupRunEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RouteMapPreview(),

            const SizedBox(height: 16),

            if (event.name.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.directions_run,
              text: "${event.distanceTargetKm} km",
            ),

            const SizedBox(height: 8),

            _InfoRow(
              icon: Icons.calendar_today,
              text: DateFormat(
                'MMM dd, yyyy – hh:mm a',
              ).format(event.startTime),
            ),

            const SizedBox(height: 8),

            if (event.location != null)
              _InfoRow(icon: Icons.place, text: event.location!.address),

            const SizedBox(height: 8),

            _InfoRow(icon: Icons.person, text: "Roger Pantil"),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
