import 'package:flutter/material.dart';

class RouteMapPreview extends StatelessWidget {
  const RouteMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Center(
        child: Text(
          "No image available.",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
