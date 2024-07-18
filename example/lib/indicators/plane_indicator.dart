import 'dart:async';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class _Cloud {
  static const _light = Color(0xFF96CDDE);
  static const _dark = Color(0xFF6AABBF);
  static const _normal = Color(0xFFACCFDA);

  static const _assets = [
    "assets/plane_indicator/cloud1.png",
    "assets/plane_indicator/cloud2.png",
    "assets/plane_indicator/cloud3.png",
    "assets/plane_indicator/cloud4.png",
  ];

  AnimationController? controller;
  final Color color;
  final AssetImage image;
  final double width;
  final double dy;
  final double initialValue;
  final Duration duration;

  _Cloud({
    required this.color,
    required this.image,
    required this.width,
    required this.dy,
    required this.initialValue,
    required this.duration,
  });
}

class PlaneIndicator extends StatefulWidget {
  final Widget child;
  final IndicatorController? controller;

  const PlaneIndicator({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<PlaneIndicator> createState() => _PlaneIndicatorState();
}

class _PlaneIndicatorState extends State<PlaneIndicator>
    with TickerProviderStateMixin {
  static final _planeTween = CurveTween(curve: Curves.easeInOut);
  late AnimationController _planeController;
  late AnimationController _planeOutInController;

  @override
  void initState() {
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _planeOutInController = AnimationController(
      vsync: this,
      duration: _completeDuration,
      value: 0.0,
    );

    _setupCloudsAnimationControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheImages());
    super.initState();
  }

  void _precacheImages() {
    for (final config in _clouds) {
      unawaited(precacheImage(config.image, context));
    }
  }

  static final _clouds = [
    _Cloud(
      color: _Cloud._dark,
      initialValue: 0.6,
      dy: 5.0,
      image: AssetImage(_Cloud._assets[1]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    _Cloud(
      color: _Cloud._light,
      initialValue: 0.15,
      dy: 18.0,
      image: AssetImage(_Cloud._assets[3]),
      width: 40,
      duration: const Duration(milliseconds: 1600),
    ),
    _Cloud(
      color: _Cloud._light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(_Cloud._assets[2]),
      width: 60,
      duration: const Duration(milliseconds: 1600),
    ),
    _Cloud(
      color: _Cloud._dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(_Cloud._assets[3]),
      width: 100,
      duration: const Duration(milliseconds: 1600),
    ),
    _Cloud(
      color: _Cloud._normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(_Cloud._assets[0]),
      width: 80,
      duration: const Duration(milliseconds: 1600),
    ),
  ];

  void _setupCloudsAnimationControllers() {
    for (final cloud in _clouds) {
      cloud.controller = AnimationController(
        vsync: this,
        duration: cloud.duration,
        value: cloud.initialValue,
      );
    }
  }

  void _startPlaneAnimation() {
    _planeController.repeat(reverse: true);
  }

  void _stopPlaneAnimation() {
    _planeController
      ..stop()
      ..animateTo(0.0, duration: const Duration(milliseconds: 100));
  }

  void _stopCloudAnimation() {
    for (final cloud in _clouds) {
      cloud.controller!.stop();
    }
  }

  void _startCloudAnimation() {
    for (final cloud in _clouds) {
      cloud.controller!.repeat();
    }
  }

  void _disposeCloudsControllers() {
    for (final cloud in _clouds) {
      cloud.controller!.dispose();
    }
  }

  @override
  void dispose() {
    _planeController.dispose();
    _planeOutInController.dispose();
    _disposeCloudsControllers();
    super.dispose();
  }

  static const _completeDuration = Duration(milliseconds: 300);
  static const _offsetToArmed = 150.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final plane = AnimatedBuilder(
          animation: _planeController,
          child: Image.asset(
            "assets/plane_indicator/plane.png",
            width: 172,
            height: 50,
            fit: BoxFit.contain,
          ),
          builder: (BuildContext context, Widget? child) {
            return Transform.translate(
              offset: Offset(0.0,
                  10 * (0.5 - _planeTween.transform(_planeController.value))),
              child: child,
            );
          },
        );
        return ClipRect(
          child: CustomRefreshIndicator(
            controller: widget.controller,
            offsetToArmed: _offsetToArmed,
            autoRebuild: false,
            durations: const RefreshIndicatorDurations(
              finalizeDuration: Duration(milliseconds: 200),
              completeDuration: _completeDuration,
            ),
            onStateChanged: (change) {
              if (change.didChange(
                from: IndicatorState.armed,
                to: IndicatorState.settling,
              )) {
                _startCloudAnimation();
                _startPlaneAnimation();
              }
              if (change.didChange(
                from: IndicatorState.loading,
              )) {
                _stopPlaneAnimation();
              }
              if (change.didChange(
                to: IndicatorState.idle,
              )) {
                _stopCloudAnimation();
                _planeOutInController.value = 0.0;
              }
              if (change.didChange(to: IndicatorState.complete)) {
                _planeOutInController.animateTo(1.0,
                    duration:
                        _completeDuration - const Duration(milliseconds: 100));
              }
            },
            onRefresh: () => Future.delayed(const Duration(seconds: 3)),
            builder: (BuildContext context, Widget child,
                IndicatorController controller) {
              final clamped = controller.clamp(0, 1);

              return AnimatedBuilder(
                animation: controller,
                child: child,
                builder: (context, child) {
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: <Widget>[
                      if (child != null) child,
                      if (!controller.side.isNone)
                        AnimatedBuilder(
                          animation: _clouds.first.controller!,
                          builder: (BuildContext context, Widget? child) {
                            return Stack(
                              clipBehavior: Clip.hardEdge,
                              alignment: Alignment.topLeft,
                              children: <Widget>[
                                Opacity(
                                  opacity: clamped.value,
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.blue[100]!.withOpacity(.2),
                                          Colors.blue[100]!.withOpacity(0.0)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                for (final cloud in _clouds)
                                  Transform.translate(
                                    offset: Offset(
                                      ((screenWidth + cloud.width) *
                                              cloud.controller!.value) -
                                          cloud.width,
                                      -cloud.width +
                                          ((cloud.width + cloud.dy) *
                                              controller.value),
                                    ),
                                    child: SizedBox(
                                      width: cloud.width,
                                      height: cloud.width,
                                      child: Image(
                                        color: cloud.color,
                                        image: cloud.image,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                /// plane
                                Transform.translate(
                                  offset: Offset(
                                    controller.state.isComplete ||
                                            controller.state.isFinalizing
                                        ? constraints.maxWidth *
                                            (0.5 -
                                                Curves.easeInCirc.transform(
                                                    _planeOutInController
                                                        .value))
                                        : constraints.maxWidth *
                                            (1.0 - (controller.value * 0.5)),
                                    -52 + (100 * controller.value),
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: SizedBox(
                                      width: 172,
                                      height: 50,
                                      child: plane,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  );
                },
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}
