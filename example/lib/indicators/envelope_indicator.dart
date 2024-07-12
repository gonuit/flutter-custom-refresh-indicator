import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class EnvelopRefreshIndicator extends StatelessWidget {
  final Widget child;
  final bool leadingScrollIndicatorVisible;
  final bool trailingScrollIndicatorVisible;
  final RefreshCallback onRefresh;
  final Color? accent;
  final IndicatorController? controller;

  static const _circleSize = 70.0;

  static const _blurRadius = 10.0;
  static const _defaultShadow = [
    BoxShadow(blurRadius: _blurRadius, color: Colors.black26)
  ];

  const EnvelopRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.leadingScrollIndicatorVisible = false,
    this.trailingScrollIndicatorVisible = false,
    this.accent,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomRefreshIndicator(
      controller: controller,
      leadingScrollIndicatorVisible: leadingScrollIndicatorVisible,
      trailingScrollIndicatorVisible: trailingScrollIndicatorVisible,
      builder: (context, child, controller) =>
          LayoutBuilder(builder: (context, constraints) {
        final widgetWidth = constraints.maxWidth;
        final widgetHeight = constraints.maxHeight;
        final letterTopWidth = (widgetWidth / 2) + 50;

        final leftValue = (widgetWidth +
                _blurRadius -
                ((letterTopWidth + _blurRadius) * controller.value / 1))
            .clamp(letterTopWidth - 100, double.infinity);

        final rightShift = widgetWidth + _blurRadius;
        final rightValue = (rightShift - (rightShift * controller.value / 1))
            .clamp(0.0, double.infinity);

        final opacity = (controller.value - 1).clamp(0, 0.5) / 0.5;

        final isNotIdle = !controller.isIdle;
        return Stack(
          children: <Widget>[
            Transform.scale(
              scale: 1 - 0.1 * controller.value.clamp(0.0, 1.0),
              child: Container(
                foregroundDecoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: theme.dividerColor,
                  ),
                ),
                child: child,
              ),
            ),
            if (isNotIdle)
              Positioned(
                right: rightValue,
                child: Container(
                  height: widgetHeight,
                  width: widgetWidth,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    boxShadow: _defaultShadow,
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            if (isNotIdle)
              Positioned(
                left: leftValue,
                child: CustomPaint(
                  size: Size(
                    letterTopWidth,
                    widgetHeight,
                  ),
                  painter: TrianglePainter(
                    strokeColor: theme.dividerColor,
                    color: theme.colorScheme.surfaceContainer,
                    strokeWidth: 2,
                  ),
                ),
              ),
            if (controller.value >= 1)
              Container(
                padding: const EdgeInsets.only(right: 100),
                child: Transform.scale(
                  scale: controller.value,
                  child: Opacity(
                    opacity: controller.isLoading || controller.state.isSettling
                        ? 1
                        : opacity,
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
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                                value: controller.isLoading ? null : 0,
                              ),
                            ),
                            Icon(
                              Icons.mail_outline,
                              color: Theme.of(context).colorScheme.onPrimary,
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
  final Color? strokeColor;
  final Color color;
  final double strokeWidth;

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  TrianglePainter({
    this.strokeColor = Colors.black,
    this.color = Colors.white,
    this.strokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = getTrianglePath(size.width, size.height);

    Paint backgroundPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(50)
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(10));
    canvas
      ..drawPath(path, shadowPaint)
      ..drawPath(path, backgroundPaint);

    final strokeColor = this.strokeColor;
    if (strokeColor != null) {
      Paint strokePaint = Paint()
        ..color = strokeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, strokePaint);
    }
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
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
