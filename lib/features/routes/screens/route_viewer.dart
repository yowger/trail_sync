import 'package:flutter/material.dart';

import 'package:trail_sync/features/home/widgets/route_map_preview.dart';
import 'package:trail_sync/features/routes/screens/create_route.dart';
import 'package:trail_sync/widgets/ui/app_divider.dart';
import 'package:trail_sync/widgets/ui/stat_item.dart';

class RouteViewerScreen extends StatelessWidget {
  const RouteViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = [
      {
        "name": "Morning Cycle",
        "distance": 5.2,
        "duration": "45",
        "activityType": "cycling",
      },
      {
        "name": "City Loop",
        "distance": 8.0,
        "duration": "65",
        "activityType": "running",
      },
      {
        "name": "Trail Adventure",

        "distance": 12.3,
        "duration": "95",
        "activityType": "walking",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.separated(
        itemCount: routes.length + 1,
        separatorBuilder: (context, index) => const AppDivider(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const CreateRouteHeader();
          }

          final route = routes[index - 1];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RouteMapPreview(),
              RouteInfoBox(
                name: route["name"] as String,
                distanceKm: route["distance"] as double,
                duration: route["duration"] as String,
                activityType: route["activityType"] as String,
              ),
            ],
          );
        },
      ),
    );
  }
}

class CreateRouteHeader extends StatelessWidget {
  const CreateRouteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Create your own route", style: TextStyle(fontSize: 16)),
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
                builder: (context) => CreateRouteScreen(),
              );
              Navigator.push(context, route);
            },
            child: const Text("Create a Route"),
          ),
        ],
      ),
    );
  }
}

class RouteInfoBox extends StatelessWidget {
  final String name;
  final double distanceKm;
  final String duration;
  final String activityType;

  const RouteInfoBox({
    super.key,
    required this.name,
    required this.distanceKm,
    required this.duration,
    required this.activityType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(getActivityIcon(activityType), size: 18),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              StatItem(value: "$distanceKm", unit: "km", label: "Distance"),
              const SizedBox(width: 40),
              StatItem(value: duration, unit: "min", label: "Est. Duration"),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Save clicked")),
                    );
                  },
                  child: const Text("Save"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("See Details clicked")),
                    );
                  },
                  child: const Text("See Details"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
