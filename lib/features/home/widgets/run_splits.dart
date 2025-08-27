import 'package:flutter/material.dart';

import 'package:trail_sync/helpers/run_split.dart' as run_split;

class RunSplits extends StatelessWidget {
  final List<run_split.Split> splits;

  const RunSplits({super.key, required this.splits});

  @override
  Widget build(BuildContext context) {
    if (splits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(child: Text("Km", style: TextStyle(fontSize: 12))),
                Expanded(
                  child: Text(
                    "Pace",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Duration",
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),

            const Divider(thickness: 1, height: 16),

            Column(
              children: splits.map((s) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text("${s.kilometer}")),

                      Expanded(
                        child: Text(
                          "${s.pace.toStringAsFixed(2)} /km",
                          textAlign: TextAlign.left,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "${s.duration.inMinutes}:${(s.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
