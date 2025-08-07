import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Good Evening, Roger!, design not final',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          _ActivityCard(
            username: 'Roger Pantil',
            activityType: 'Morning Run',
            distance: '5.2 km',
            duration: '32 min',
            timeAgo: '2h ago',
          ),
          const SizedBox(height: 16),

          _ActivityCard(
            username: 'Jane Doe',
            activityType: 'Cycling',
            distance: '18.7 km',
            duration: '1h 5m',
            timeAgo: '5h ago',
          ),
          const SizedBox(height: 16),

          _ActivityCard(
            username: 'John Smith',
            activityType: 'Trail Run',
            distance: '12.4 km',
            duration: '1h 15m',
            timeAgo: '1 day ago',
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String username;
  final String activityType;
  final String distance;
  final String duration;
  final String timeAgo;

  const _ActivityCard({
    required this.username,
    required this.activityType,
    required this.distance,
    required this.duration,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$activityType • $timeAgo'),
          ),

          Container(
            height: 160,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.map, size: 40, color: Colors.grey),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.directions_run, size: 18, color: Colors.teal),
                const SizedBox(width: 4),
                Text(distance),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 18, color: Colors.orange),
                const SizedBox(width: 4),
                Text(duration),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  label: const Text('Like'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('Comment'),
                ),
              ],
            ),
          ),

          Text('like n comment maybe futures if nay time.'),
        ],
      ),
    );
  }
}
