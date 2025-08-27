import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;

  const ExpandableText({super.key, required this.text, this.trimLines = 3});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  bool isOverflowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    final textSpan = TextSpan(
      text: widget.text,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    );
    final tp = TextPainter(
      text: textSpan,
      maxLines: widget.trimLines,
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout(maxWidth: context.size?.width ?? double.infinity);

    if (mounted) {
      setState(() {
        isOverflowing = tp.didExceedMaxLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          maxLines: isExpanded ? null : widget.trimLines,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (isOverflowing) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Text(
              isExpanded ? "Show less" : "Show more",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
