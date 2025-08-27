import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Fetch user data with userId or display it
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Center(child: Text('User ID: $userId')),
    );
  }
}
