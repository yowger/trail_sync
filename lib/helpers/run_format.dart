String formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final hours = twoDigits(d.inHours);
  final minutes = twoDigits(d.inMinutes.remainder(60));
  final seconds = twoDigits(d.inSeconds.remainder(60));
  return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
}
