import 'package:flutter/material.dart';
import 'package:trail_sync/screens/upcoming_events_page.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Events & Routes"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Events"),
              Tab(text: "Routes"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UpcomingEventsScreen(), // your events page
            UpcomingEventsScreen(), // your events page
            // RoutesListScreen(),    // a page that lists saved routes
          ],
        ),
      ),
    );
  }
}
