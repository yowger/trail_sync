import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:intl/intl.dart';
import 'package:trail_sync/features/home/widgets/stat_item.dart';

class ActivityCard extends StatelessWidget {
  final String? activityName;
  final String? address;
  final String username;
  final String? userImageUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onCardTap;
  final String? activityType;
  final String distance;
  final String duration;
  final String? pace;
  final List<LatLng> trailPoints;
  final DateTime? date;

  const ActivityCard({
    super.key,
    this.activityName,
    this.address,
    required this.username,
    this.userImageUrl,
    this.onAvatarTap,
    this.onCardTap,
    this.activityType,
    required this.distance,
    required this.duration,
    this.pace,
    required this.trailPoints,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCardTap,
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(
                    username: username,
                    userImageUrl: userImageUrl,
                    onTap: onAvatarTap,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: UserInfo(
                      username: username,
                      date: date,
                      address: address,
                      activityType: activityType ?? "",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (activityName != null && activityName!.isNotEmpty)
                Text(
                  activityName!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  StatItem(value: distance, unit: "km", label: "Distance"),
                  const SizedBox(width: 36),
                  StatItem(value: duration, label: "Duration"),
                  const SizedBox(width: 36),
                  StatItem(value: pace ?? "0", unit: "/km", label: "Avg Pace"),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final String username;
  final DateTime? date;
  final String? address;
  final VoidCallback? onTap;
  final String activityType;
  const UserInfo({
    super.key,
    required this.username,
    this.date,
    this.address,
    this.onTap,
    required this.activityType,
  });
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String formattedDate = '';
    String formattedTime = '';
    if (date != null) {
      if (date!.year == now.year) {
        formattedDate = DateFormat('MMM d yyyy').format(date!);
      } else {
        formattedDate = DateFormat('MMM d, yyyy').format(date!);
      }
      formattedTime = DateFormat('h:mm a').format(date!);
    }
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          if (date != null)
            Row(
              children: [
                Icon(getActivityIcon(activityType), size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    [
                      "$formattedDate at $formattedTime",
                      if (address != null && address!.isNotEmpty) address!,
                    ].join(" · "),
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String username;
  final String? userImageUrl;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.username,
    this.userImageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundImage: userImageUrl != null
            ? NetworkImage(userImageUrl!)
            : null,
        backgroundColor: Colors.grey[300],
        child: userImageUrl == null
            ? Text(
                username.isNotEmpty ? username[0].toUpperCase() : "?",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              )
            : null,
      ),
    );
  }
}
