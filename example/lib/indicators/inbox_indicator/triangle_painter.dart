import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  TrianglePainter(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 3,
      this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;
    final path = getTrianglePath(size.width, size.height);
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(50)
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(10));
    canvas.drawPath(path, shadowPaint);

    canvas.drawPath(path, paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, y / 2)
      ..lineTo(x, 0)
      ..lineTo(x, y)
      ..lineTo(0, y / 2);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
