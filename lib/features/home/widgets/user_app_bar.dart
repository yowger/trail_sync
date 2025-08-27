import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAppBar extends StatelessWidget {
  final AsyncValue userAsync;
  const UserAppBar({super.key, required this.userAsync});

  @override
  Widget build(BuildContext context) {
    return userAsync.when(
      data: (user) {
        if (user == null) return const Text("Welcome");
        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 8),
            Text(
              user.displayName ?? 'You',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text("Error"),
    );
  }
}
