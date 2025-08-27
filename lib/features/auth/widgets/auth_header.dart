import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String text;

  const AuthHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
