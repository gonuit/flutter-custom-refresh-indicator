import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class EnvelopRefreshIndicator extends StatelessWidget {
  final Widget child;
  final bool leadingScrollIndicatorVisible;
  final bool trailingScrollIndicatorVisible;
  final RefreshCallback onRefresh;
  final Color? accent;

  static const _circleSize = 70.0;

  static const _defaultShadow = [
    BoxShadow(blurRadius: 10, color: Colors.black26)
  ];

  const EnvelopRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.leadingScrollIndicatorVisible = false,
    this.trailingScrollIndicatorVisible = false,
    this.accent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      leadingScrollIndicatorVisible: leadingScrollIndicatorVisible,
      trailingScrollIndicatorVisible: trailingScrollIndicatorVisible,
      builder: (context, child, controller) =>
          LayoutBuilder(builder: (context, constraints) {
        final widgetWidth = constraints.maxWidth;
        final widgetHeight = constraints.maxHeight;
        final letterTopWidth = (widgetWidth / 2) + 50;

        final leftValue =
            (widgetWidth - (letterTopWidth * controller.value / 1))
                .clamp(letterTopWidth - 100, double.infinity);

        final rightValue = (widgetWidth - (widgetWidth * controller.value / 1))
            .clamp(0.0, double.infinity);

        final opacity = (controller.value - 1).clamp(0, 0.5) / 0.5;
        return Stack(
          children: <Widget>[
            Transform.scale(
              scale: 1 - 0.1 * controller.value.clamp(0.0, 1.0),
              child: child,
            ),
            Positioned(
              right: rightValue,
              child: Container(
                height: widgetHeight,
                width: widgetWidth,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: _defaultShadow,
                ),
              ),
            ),
            Positioned(
              left: leftValue,
              child: CustomPaint(
                painter: TrianglePainter(
                  strokeColor: Colors.white,
                  paintingStyle: PaintingStyle.fill,
                ),
                child: SizedBox(
                  height: widgetHeight,
                  width: letterTopWidth,
                ),
              ),
            ),
            if (controller.value >= 1)
              Container(
                padding: const EdgeInsets.only(right: 100),
                child: Transform.scale(
                  scale: controller.value,
                  child: Opacity(
                    opacity: controller.isLoading ? 1 : opacity,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: _circleSize,
                        height: _circleSize,
                        decoration: BoxDecoration(
                          boxShadow: _defaultShadow,
                          color:
                              accent ?? Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: double.infinity,
                              width: double.infinity,
                              child: CircularProgressIndicator(
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.black),
                                value: controller.isLoading ? null : 0,
                              ),
                            ),
                            const Icon(
                              Icons.mail_outline,
                              color: Colors.white,
                              size: 35,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
          ],
        );
      }),
      child: child,
      onRefresh: () => Future<void>.delayed(const Duration(seconds: 2)),
    );
  }
}

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
