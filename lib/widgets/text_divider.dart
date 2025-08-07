import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  final String label;

  const TextDivider({super.key, this.label = ''});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: Divider(thickness: 0.7, color: Colors.black26)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label, style: const TextStyle(color: Colors.black45)),
        ),
        const Expanded(child: Divider(thickness: 0.7, color: Colors.black26)),
      ],
    );
  }
}
