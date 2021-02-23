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
  final Color? color;
  final AssetImage? image;
  final double? width;
  final double? dy;
  final double? initialValue;
  final Duration? duration;
  _Cloud({
    this.color,
    this.image,
    this.width,
    this.dy,
    this.initialValue,
    this.duration,
  });
}

class PlaneIndicator extends StatefulWidget {
  final Widget child;
  const PlaneIndicator({
    required this.child,
  });

  @override
  _PlaneIndicatorState createState() => _PlaneIndicatorState();
}

class _PlaneIndicatorState extends State<PlaneIndicator>
    with TickerProviderStateMixin {
  static final _planeTween = CurveTween(curve: Curves.easeInOut);
  late AnimationController _planeController;
  IndicatorState? _prevState;

  @override
  void initState() {
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _setupCloudsAnimationControllers();
    super.initState();
  }

  static final _clouds = [
    _Cloud(
      color: _Cloud._dark,
      initialValue: 0.6,
      dy: 10.0,
      image: AssetImage(_Cloud._assets[1]),
      width: 100,
      duration: Duration(milliseconds: 1600),
    ),
    _Cloud(
      color: _Cloud._light,
      initialValue: 0.15,
      dy: 25.0,
      image: AssetImage(_Cloud._assets[3]),
      width: 40,
      duration: Duration(milliseconds: 1600),
    ),
    _Cloud(
      color: _Cloud._light,
      initialValue: 0.3,
      dy: 65.0,
      image: AssetImage(_Cloud._assets[2]),
      width: 60,
      duration: Duration(milliseconds: 1600),
    ),
    _Cloud(
      color: _Cloud._dark,
      initialValue: 0.8,
      dy: 70.0,
      image: AssetImage(_Cloud._assets[3]),
      width: 100,
      duration: Duration(milliseconds: 1600),
    ),
    _Cloud(
      color: _Cloud._normal,
      initialValue: 0.0,
      dy: 10,
      image: AssetImage(_Cloud._assets[0]),
      width: 80,
      duration: Duration(milliseconds: 1600),
    ),
  ];

  void _setupCloudsAnimationControllers() {
    for (final cloud in _clouds)
      cloud.controller = AnimationController(
        vsync: this,
        duration: cloud.duration,
        value: cloud.initialValue,
      );
  }

  void _startPlaneAnimation() {
    _planeController.repeat(reverse: true);
  }

  void _stopPlaneAnimation() {
    _planeController
      ..stop()
      ..animateTo(0.0, duration: Duration(milliseconds: 100));
  }

  void _stopCloudAnimation() {
    for (final cloud in _clouds) cloud.controller!.stop();
  }

  void _startCloudAnimation() {
    for (final cloud in _clouds) cloud.controller!.repeat();
  }

  void _disposeCloudsControllers() {
    for (final cloud in _clouds) cloud.controller!.dispose();
  }

  @override
  void dispose() {
    _planeController.dispose();
    _disposeCloudsControllers();
    super.dispose();
  }

  static const _offsetToArmed = 150.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          offset: Offset(
              0.0, 10 * (0.5 - _planeTween.transform(_planeController.value))),
          child: child,
        );
      },
    );
    return CustomRefreshIndicator(
      offsetToArmed: _offsetToArmed,
      child: widget.child,
      onRefresh: () => Future.delayed(const Duration(seconds: 3)),
      builder:
          (BuildContext context, Widget child, IndicatorController controller) {
        return AnimatedBuilder(
          animation: controller,
          child: child,
          builder: (context, child) {
            final currentState = controller.state;
            if (_prevState == IndicatorState.armed &&
                currentState == IndicatorState.loading) {
              _startCloudAnimation();
              _startPlaneAnimation();
            } else if (_prevState == IndicatorState.loading &&
                currentState == IndicatorState.hiding) {
              _stopPlaneAnimation();
            } else if (_prevState == IndicatorState.hiding &&
                currentState != _prevState) {
              _stopCloudAnimation();
            }

            _prevState = currentState;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                if (_prevState != IndicatorState.idle)
                  Container(
                    height: _offsetToArmed * controller.value,
                    color: Color(0xFFFDFEFF),
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _clouds.first.controller!,
                      builder: (BuildContext context, Widget? child) {
                        return Stack(
                          clipBehavior: Clip.hardEdge,
                          children: <Widget>[
                            for (final cloud in _clouds)
                              Transform.translate(
                                offset: Offset(
                                  ((screenWidth + cloud.width!) *
                                          cloud.controller!.value) -
                                      cloud.width!,
                                  cloud.dy! * controller.value,
                                ),
                                child: OverflowBox(
                                  minWidth: cloud.width,
                                  minHeight: cloud.width,
                                  maxHeight: cloud.width,
                                  maxWidth: cloud.width,
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    child: Image(
                                      color: cloud.color,
                                      image: cloud.image!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),

                            /// plane
                            Center(
                              child: OverflowBox(
                                child: plane,
                                maxWidth: 172,
                                minWidth: 172,
                                maxHeight: 50,
                                minHeight: 50,
                                alignment: Alignment.center,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                Transform.translate(
                  offset: Offset(0.0, _offsetToArmed * controller.value),
                  child: child,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
