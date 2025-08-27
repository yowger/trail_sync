import 'package:flutter/material.dart';

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
        backgroundColor: Colors.blue,
        child: userImageUrl == null
            ? Text(
                username.isNotEmpty ? username[0].toUpperCase() : "?",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
