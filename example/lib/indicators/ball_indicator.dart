import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

extension _GetRandomFromList<T> on List<T> {
  T get random {
    return this[math.Random().nextInt(length)];
  }
}

class ShakeState {
  final bool isInitial;
  final Offset shift;

  ShakeState({
    required this.shift,
    required this.isInitial,
  });
}

class BallIndicator extends StatefulWidget {
  final Widget child;
  final AsyncCallback onRefresh;
  final double acceleration;
  final double ballRadius;
  final double shakeOffset;
  final List<Color> ballColors;
  final double strokeWidth;
  final IndicatorController? controller;

  const BallIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.acceleration = 1.2,
    this.ballRadius = 25.0,
    this.strokeWidth = 3.0,
    this.shakeOffset = 4.0,
    this.ballColors = const [Colors.blue],
    this.controller,
  }) : assert(ballColors.length > 0, 'ballColors cannot be empty.');

  @override
  State<BallIndicator> createState() => _BallIndicatorState();
}

class _BallIndicatorState extends State<BallIndicator>
    with TickerProviderStateMixin {
  IndicatorController? _internalIndicatorController;
  IndicatorController get controller =>
      widget.controller ??
      (_internalIndicatorController ??= IndicatorController());

  late final Ticker _ticker;
  final _ballPosition = ValueNotifier<Offset>(Offset.zero);

  Offset _direction = Offset.zero;
  double _lastAngle = 0;
  Size _rectSize = Size.zero;
  late Color _ballColor;

  late final _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 50),
  );
  late final _arrowOpacityController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final _centerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  ShakeState _shakeState = ShakeState(shift: Offset.zero, isInitial: true);

  @override
  void initState() {
    _ballColor =
        widget.ballColors.length > 1 ? widget.ballColors.random : Colors.blue;

    _ticker = createTicker(_onTick);
    _shakeController.addStatusListener(_onShakeStatusChanged);
    _centerController.addListener(_onCenterChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BallIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller &&
        widget.controller != null) {
      _internalIndicatorController?.dispose();
      _internalIndicatorController = null;
    }

    assert(
      widget.controller == null ||
          (widget.controller != null && _internalIndicatorController == null),
      'An internal indicator should not exist when an external indicator is provided.',
    );
  }

  void _onShakeStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && _shakeState.isInitial) {
      _shakeState = ShakeState(shift: _shakeState.shift, isInitial: false);
      _shakeController.reverse(from: 1.0);
    }
  }

  void _onCenterChanged() {
    _ballPosition.value = _centerTween.transform(_centerController.value);
  }

  void _onHitBorder(Offset direction) {
    setState(() {
      _shakeState = ShakeState(
        shift: direction * widget.shakeOffset,
        isInitial: true,
      );

      // Update ball color
      if (widget.ballColors.length > 1) {
        final colors =
            widget.ballColors.where((color) => color != _ballColor).toList();
        _ballColor = colors.random;
      }

      _shakeController.forward(from: 0.0);
      HapticFeedback.lightImpact().ignore();
    });
  }

  Duration _prevTickerDuration = Duration.zero;
  void _onTick(Duration time) {
    final delta = time - _prevTickerDuration;
    _prevTickerDuration = time;

    Offset ballPosition = _ballPosition.value +
        _direction * delta.inMilliseconds.toDouble() * widget.acceleration;

    final Size ballSafeSpace = Size(_rectSize.width - widget.ballRadius * 2,
        _rectSize.height - widget.ballRadius * 2);

    if (ballPosition.dx < 0) {
      _onHitBorder(_direction);

      _direction = Offset(-_direction.dx, _direction.dy);
      ballPosition = Offset(-ballPosition.dx, ballPosition.dy);
    } else if (ballPosition.dx > ballSafeSpace.width) {
      _onHitBorder(_direction);

      _direction = Offset(-_direction.dx, _direction.dy);
      ballPosition = Offset(
        ballPosition.dx - (ballPosition.dx - ballSafeSpace.width),
        ballPosition.dy,
      );
    }

    if (ballPosition.dy < 0) {
      _onHitBorder(_direction);

      _direction = Offset(_direction.dx, -_direction.dy);
      ballPosition = Offset(ballPosition.dx, -ballPosition.dy);
    } else if (ballPosition.dy > ballSafeSpace.height) {
      _onHitBorder(_direction);

      _direction = Offset(_direction.dx, -_direction.dy);
      ballPosition = Offset(
        ballPosition.dx,
        ballPosition.dy - (ballPosition.dy - ballSafeSpace.height),
      );
    }

    _ballPosition.value = ballPosition;
  }

  double _calculateAngle({
    required Offset origin,
    required Offset point,
  }) {
    final double angle =
        math.atan2(point.dy - origin.dy, point.dx - origin.dx) - (math.pi / 2);

    final normalizedAngle = (angle + math.pi) % (2 * math.pi) - math.pi;
    return normalizedAngle;
  }

  final _centerTween = Tween<Offset>(
    begin: Offset.zero,
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    final ballRadius = widget.ballRadius;
    final ballSize = ballRadius * 2;

    return LayoutBuilder(builder: (context, constraints) {
      _rectSize = constraints.biggest;

      const arrowRadius = 100.0;

      final center = Offset(
        constraints.maxWidth / 2,
        constraints.maxHeight * 0.25 + arrowRadius,
      );

      return CustomRefreshIndicator(
        controller: controller,
        trailingScrollIndicatorVisible: false,
        leadingScrollIndicatorVisible: false,
        onRefresh: widget.onRefresh,
        durations: const RefreshIndicatorDurations(
          completeDuration: Duration(seconds: 1),
        ),
        autoRebuild: false,
        onStateChanged: (change) {
          if (change.didChange(to: IndicatorState.settling)) {
            final angle = _lastAngle;

            const scale = 1.0;

            final target = Offset(
              center.dx + scale * math.sin(angle),
              center.dy - scale * math.cos(angle),
            );
            _ballPosition.value = Offset(
              center.dx - ballRadius,
              center.dy - ballRadius,
            );
            _direction = target - center;
            _ticker.start();
          }
          if (change.didChange(to: IndicatorState.complete)) {
            _prevTickerDuration = Duration.zero;
            _direction = Offset.zero;
            _ticker.stop();

            _centerTween
              ..end = Offset(center.dx - ballRadius, center.dy - ballRadius)
              ..begin = _ballPosition.value;
            _centerController.forward(from: 0.0);
          }

          if (change.didChange(to: IndicatorState.armed)) {
            _arrowOpacityController.forward(from: 0.0);
            HapticFeedback.selectionClick().ignore();
          } else if (change.didChange(from: IndicatorState.armed)) {
            _arrowOpacityController.reverse(from: 1.0);
            HapticFeedback.selectionClick().ignore();
          }
        },
        builder: (context, child, controller) {
          final ball = AnimatedContainer(
            duration: const Duration(milliseconds: 60),
            curve: Curves.easeIn,
            decoration: BoxDecoration(
              color: _ballColor,
              shape: BoxShape.circle,
              border: controller.isArmed
                  ? Border.all(
                      color: Colors.white,
                      width: widget.strokeWidth,
                    )
                  : null,
            ),
            width: ballSize,
            height: ballSize,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: controller.isComplete || controller.isFinalizing
                  ? const Icon(
                      Icons.check,
                      color: Colors.black,
                    )
                  : null,
            ),
          );

          final clamped = controller.clamp(0.0, 1.0);

          return Stack(
            children: [
              PositionedTransition(
                rect: RelativeRectTween(
                  begin: RelativeRect.fill,
                  end: RelativeRect.fill.shift(_shakeState.shift),
                ).animate(_shakeController),
                child: child,
              ),
              if (!controller.isIdle)
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final event = controller.dragDetails;

                    final double angle;
                    if (event != null) {
                      _lastAngle = angle = _calculateAngle(
                        origin: center,
                        point: event.localPosition,
                      );
                    } else {
                      angle = _lastAngle;
                    }

                    return Positioned(
                      left: center.dx - arrowRadius,
                      top: center.dy - arrowRadius,
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _arrowOpacityController,
                          curve: Curves.easeIn,
                        ),
                        child: Arrow(
                          radius: arrowRadius,
                          angle: angle,
                          strokeWidth: widget.strokeWidth,
                          distanceFromCenter: ballSize * 0.75,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              if (controller.isLoading ||
                  controller.isSettling ||
                  controller.isComplete)
                Align(
                  alignment: Alignment.topLeft,
                  child: AnimatedBuilder(
                    animation: _ballPosition,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: _ballPosition.value,
                        child: ball,
                      );
                    },
                  ),
                ),
              if (controller.isDragging ||
                  controller.isArmed ||
                  controller.isCanceling ||
                  controller.isFinalizing)
                PositionedTransition(
                  rect: RelativeRectTween(
                    begin: RelativeRect.fromRect(
                      Rect.fromLTRB(
                        center.dx - ballRadius,
                        -ballRadius,
                        center.dx + ballRadius,
                        0,
                      ),
                      Offset.zero & constraints.biggest,
                    ),
                    end: RelativeRect.fromRect(
                      Rect.fromLTRB(
                        center.dx - ballRadius,
                        center.dy - ballRadius,
                        center.dx + ballRadius,
                        center.dy + ballRadius,
                      ),
                      Offset.zero & constraints.biggest,
                    ),
                  ).animate(clamped),
                  child: ball,
                ),
            ],
          );
        },
        child: widget.child,
      );
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _ballPosition.dispose();
    _shakeController.dispose();
    _arrowOpacityController.dispose();
    _centerController.dispose();
    _internalIndicatorController?.dispose();
    super.dispose();
  }
}

class Arrow extends StatelessWidget {
  final double angle;
  final Color color;
  final double strokeWidth;
  final double radius;

  /// How far from the center point the arrow should be drawn. It must be smaller than the radius.
  final double distanceFromCenter;

  const Arrow({
    super.key,
    required this.angle,
    required this.radius,
    required this.color,
    required this.strokeWidth,
    this.distanceFromCenter = 0.0,
  })  : assert(
          radius > distanceFromCenter,
          'Distance from center needs to be smaller than radius',
        ),
        assert(
          distanceFromCenter >= 0,
          'The distance from the center must be greater than or equal to 0',
        ),
        assert(
          radius >= 0,
          'The radius must be greater than or equal to 0',
        );

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(radius * 2),
      painter: ArrowPainter(
        angle: angle,
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        distanceFromCenter: distanceFromCenter,
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final double angle;
  final Color color;
  final double strokeWidth;
  final double radius;
  final double distanceFromCenter;

  ArrowPainter({
    required this.color,
    required this.angle,
    required this.strokeWidth,
    required this.radius,
    required this.distanceFromCenter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * 0.5, size.height * 0.5);
    double distance = radius; // Distance from start to end initially

    final end = Offset(
      start.dx + distance * math.sin(angle),
      start.dy - distance * math.cos(angle),
    );

    /// Calculate the vector from A to B
    Offset direction = end - start;
    // Calculate the magnitude of the direction vector
    double magnitude =
        math.sqrt(direction.dx * direction.dx + direction.dy * direction.dy);

    /// Normalize the vector
    Offset unitVector =
        Offset(direction.dx / magnitude, direction.dy / magnitude);

    /// Scale the unit vector by 50 to get the new point offset
    Offset startFrom = start + unitVector * distanceFromCenter;

    canvas.drawLine(startFrom, end, paint);

    /// Arrowhead settings
    double arrowLength = 20; // Length of the arrow lines
    double arrowAngle =
        math.pi / 6; // Angle of the arrow lines from the main line

    /// Calculating arrowhead lines
    final arrowEnd1 = Offset(
        end.dx - arrowLength * math.sin(angle - arrowAngle),
        end.dy + arrowLength * math.cos(angle - arrowAngle));
    final arrowEnd2 = Offset(
        end.dx - arrowLength * math.sin(angle + arrowAngle),
        end.dy + arrowLength * math.cos(angle + arrowAngle));

    final path = Path()
      ..moveTo(arrowEnd1.dx, arrowEnd1.dy)
      ..lineTo(end.dx, end.dy)
      ..lineTo(arrowEnd2.dx, arrowEnd2.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.distanceFromCenter != distanceFromCenter ||
        oldDelegate.radius != radius;
  }
}
