import 'package:flutter/material.dart';

class CreateRouteScreen extends StatelessWidget {
  const CreateRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Create Route")),
      body: Center(
        child: Text(
          "Route creation is not supported on this device.\nPlease use the web app.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
