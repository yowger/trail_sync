import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  final double thickness;
  final Color? color;
  final double indent;
  final double endIndent;

  const AppDivider({
    super.key,
    this.thickness = 5,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color ?? Colors.grey[100],
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
