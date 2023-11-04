import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

enum WarpAnimationState {
  stopped,
  playing,
}

typedef StarColorGetter = Color Function(int index);

class WarpIndicator extends StatefulWidget {
  final Widget child;
  final int starsCount;
  final AsyncCallback onRefresh;
  final IndicatorController? controller;
  final Color skyColor;
  final StarColorGetter starColorGetter;
  final Key? indicatorKey;

  const WarpIndicator({
    super.key,
    this.indicatorKey,
    this.controller,
    required this.onRefresh,
    required this.child,
    this.starsCount = 30,
    this.skyColor = Colors.black,
    this.starColorGetter = _defaultStarColorGetter,
  });

  static Color _defaultStarColorGetter(int index) =>
      HSLColor.fromAHSL(1, Random().nextDouble() * 360, 1, 0.98).toColor();

  @override
  State<WarpIndicator> createState() => _WarpIndicatorState();
}

class _WarpIndicatorState extends State<WarpIndicator> with SingleTickerProviderStateMixin {
  static const _indicatorSize = 150.0;
  final _random = Random();
  WarpAnimationState _state = WarpAnimationState.stopped;

  List<Star> stars = [];
  final _offsetTween = Tween<Offset>(
    begin: Offset.zero,
    end: Offset.zero,
  );
  final _angleTween = Tween<double>(
    begin: 0,
    end: 0,
  );

  late AnimationController shakeController;

  static final _scaleTween = Tween(begin: 1.0, end: 0.75);
  static final _radiusTween = Tween(begin: 0.0, end: 16.0);

  @override
  void initState() {
    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    super.initState();
  }

  Offset _getRandomOffset() => Offset(
        _random.nextInt(10) - 5,
        _random.nextInt(10) - 5,
      );

  double _getRandomAngle() {
    final degrees = ((_random.nextDouble() * 2) - 1);
    final radians = degrees == 0 ? 0.0 : degrees / 360.0;
    return radians;
  }

  void _shiftAndGenerateRandomShakeTransform() {
    _offsetTween.begin = _offsetTween.end;
    _offsetTween.end = _getRandomOffset();

    _angleTween.begin = _angleTween.end;
    _angleTween.end = _getRandomAngle();
  }

  void _startShakeAnimation() {
    _shiftAndGenerateRandomShakeTransform();
    shakeController.animateTo(1.0);
    _state = WarpAnimationState.playing;
    stars = List.generate(
      widget.starsCount,
      (index) => Star(initialColor: widget.starColorGetter(index)),
    );
  }

  void _resetShakeAnimation() {
    _shiftAndGenerateRandomShakeTransform();
    shakeController.value = 0.0;
    shakeController.animateTo(1.0);
  }

  void _stopShakeAnimation() {
    _offsetTween.end = Offset.zero;
    _angleTween.end = 0.0;
    _state = WarpAnimationState.stopped;
    _shiftAndGenerateRandomShakeTransform();
    shakeController.stop();
    shakeController.value = 0.0;
    stars = [];
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      key: widget.indicatorKey,
      controller: widget.controller,
      offsetToArmed: _indicatorSize,
      leadingScrollIndicatorVisible: false,
      trailingScrollIndicatorVisible: false,
      onRefresh: widget.onRefresh,
      autoRebuild: false,
      onStateChanged: (change) {
        if (change.didChange(to: IndicatorState.loading)) {
          _startShakeAnimation();
        } else if (change.didChange(to: IndicatorState.idle)) {
          _stopShakeAnimation();
        }
      },
      child: widget.child,
      builder: (
        BuildContext context,
        Widget child,
        IndicatorController controller,
      ) {
        final animation = Listenable.merge([controller, shakeController]);
        return Stack(
          children: <Widget>[
            AnimatedBuilder(
                animation: shakeController,
                builder: (_, __) {
                  return LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return CustomPaint(
                        painter: Sky(
                          stars: stars,
                          color: widget.skyColor,
                        ),
                        child: const SizedBox.expand(),
                      );
                    },
                  );
                }),
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return Transform.scale(
                  scale: _scaleTween.transform(controller.value),
                  child: Builder(builder: (context) {
                    if (shakeController.value == 1.0 && _state == WarpAnimationState.playing) {
                      SchedulerBinding.instance.addPostFrameCallback((_) => _resetShakeAnimation());
                    }
                    return Transform.rotate(
                      angle: _angleTween.transform(shakeController.value),
                      child: Transform.translate(
                        offset: _offsetTween.transform(shakeController.value),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            _radiusTween.transform(controller.value),
                          ),
                          child: child,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    shakeController.dispose();
    super.dispose();
  }
}

class Star {
  Offset? position;
  Color? color;
  double value;
  late Offset speed;
  final Color initialColor;
  late double angle;

  Star({
    required this.initialColor,
  }) : value = 0.0;

  static const _minOpacity = 0.1;
  static const _maxOpacity = 1.0;

  void _init(Rect rect) {
    position = rect.center;
    value = 0.0;
    final random = Random();
    angle = random.nextDouble() * pi * 3;
    speed = Offset(cos(angle), sin(angle));
    const minSpeedScale = 20;
    const maxSpeedScale = 35;
    final speedScale = minSpeedScale + random.nextInt(maxSpeedScale - minSpeedScale).toDouble();
    speed = speed.scale(
      speedScale,
      speedScale,
    );
    final t = speedScale / maxSpeedScale;
    final opacity = _minOpacity + (_maxOpacity - _minOpacity) * t;
    color = initialColor.withOpacity(opacity);
  }

  draw(Canvas canvas, Rect rect) {
    if (position == null) {
      _init(rect);
    }

    value++;
    final startPosition = Offset(position!.dx, position!.dy);
    final endPosition = position! + (speed * (value * 0.3));
    position = speed + position!;
    final paint = Paint()..color = color!;

    final startShiftAngle = angle + (pi / 2);
    final startShift = Offset(cos(startShiftAngle), sin(startShiftAngle));
    final shiftedStartPosition = startPosition + (startShift * (0.75 + value * 0.01));

    final endShiftAngle = angle + (pi / 2);
    final endShift = Offset(cos(endShiftAngle), sin(endShiftAngle));
    final shiftedEndPosition = endPosition + (endShift * (1.5 + value * 0.01));

    final path = Path()
      ..moveTo(startPosition.dx, startPosition.dy)
      ..lineTo(startPosition.dx, startPosition.dy)
      ..lineTo(shiftedStartPosition.dx, shiftedStartPosition.dy)
      ..lineTo(shiftedEndPosition.dx, shiftedEndPosition.dy)
      ..lineTo(endPosition.dx, endPosition.dy);

    if (!rect.contains(startPosition)) {
      _init(rect);
    }

    canvas.drawPath(path, paint);
  }
}

class Sky extends CustomPainter {
  final List<Star> stars;
  final Color color;

  Sky({
    required this.stars,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;

    canvas.drawRect(rect, Paint()..color = color);

    for (final star in stars) {
      star.draw(canvas, rect);
    }
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      var rect = Offset.zero & size;

      return [
        CustomPainterSemantics(
          rect: rect,
          properties: const SemanticsProperties(
            label: 'light speed animation.',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  @override
  bool shouldRepaint(Sky oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(Sky oldDelegate) => false;
}
