import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<Uint8List> createCircularMarkerWithImage(
  String assetPath, {
  double size = 64,
}) async {
  final ByteData data = await rootBundle.load(assetPath);
  final ui.Codec codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: size.toInt(),
    targetHeight: size.toInt(),
  );
  final ui.FrameInfo fi = await codec.getNextFrame();
  final ui.Image image = fi.image;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final radius = size / 2;

  final paint = Paint();

  paint.color = Colors.white;
  canvas.drawCircle(Offset(radius, radius), radius, paint);

  canvas.clipPath(Path()..addOval(Rect.fromLTWH(0, 0, size, size)));

  paint.color = Colors.white;
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    Rect.fromLTWH(0, 0, size, size),
    paint,
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
