import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:trail_sync/features/home/widgets/activity_card.dart';
import 'package:trail_sync/features/home/widgets/map_details.dart';
import 'package:trail_sync/features/home/widgets/run_splits.dart';
import 'package:trail_sync/helpers/run_format.dart';
import 'package:trail_sync/models/run.dart';
import 'package:trail_sync/helpers/run_split.dart' as run_split;
import 'package:trail_sync/widgets/ui/app_divider.dart';

class RunDetailScreen extends StatefulWidget {
  final Run run;

  const RunDetailScreen({super.key, required this.run});

  @override
  State<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends State<RunDetailScreen> {
  MapLibreMapController? mapController;

  @override
  Widget build(BuildContext context) {
    final splits = run_split.calculateSplits(widget.run.points);
    final pace = widget.run.avgPaceMinPerKm?.toStringAsFixed(2);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context),
      body: Stack(
        children: [
          if (widget.run.points.isNotEmpty)
            Positioned.fill(
              child: MapDetails(
                run: widget.run,
                controllerSetter: (c) => mapController = c,
              ),
            ),

          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.15,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black26.withValues(alpha: 0.10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      ActivityCard(
                        activityName: widget.run.name,
                        description: widget.run.description,
                        username: widget.run.name,
                        userImageUrl: widget.run.user.imageUrl,
                        address: widget.run.address,
                        activityType: widget.run.mode,
                        distance: widget.run.distanceKm.toStringAsFixed(2),
                        duration: formatDuration(
                          Duration(seconds: widget.run.durationSec),
                        ),
                        pace: pace,
                        date: widget.run.startTime,
                        trailPoints: widget.run.points
                            .map((p) => LatLng(p.lat, p.lng))
                            .toList(),
                      ),

                      AppDivider(),

                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Splits",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      RunSplits(splits: splits),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Ink(
        decoration: const ShapeDecoration(
          color: Colors.black54,
          shape: CircleBorder(),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    ),
  );
}
