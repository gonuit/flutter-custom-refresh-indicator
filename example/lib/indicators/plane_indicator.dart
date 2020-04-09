import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/custom_indicator.dart';
import 'package:flutter/material.dart';

class PlaneIndicator extends StatefulWidget {
  final IndicatorData data;
  final Widget child;
  const PlaneIndicator(this.child, this.data);

  @override
  _PlaneIndicatorState createState() => _PlaneIndicatorState();
}

class _PlaneIndicatorState extends State<PlaneIndicator>
    with TickerProviderStateMixin {
  AnimationController _planeController;
  AnimationController _cloudsController;
  IndicatorState _prevState;

  @override
  void initState() {
    _prevState = widget.data.state;
    _planeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _cloudsController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    super.initState();
  }

  static final _planeTween = CurveTween(curve: Curves.easeInOut);

  void _startPlaneAnimation() {
    _planeController.repeat(reverse: true);
    _cloudsController.repeat(reverse: false);
  }

  void _stopPlaneAnimation() {
    _planeController
      ..stop()
      ..animateTo(0.0, duration: Duration(milliseconds: 100));

    _cloudsController
      ..stop()
      ..animateTo(0.0, duration: Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _planeController.dispose();
    _cloudsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plane = AnimatedBuilder(
      animation: _planeController,
      child: Image.asset(
        "assets/plane_indicator/plane.png",
        width: 172,
        height: 50,
        fit: BoxFit.contain,
      ),
      builder: (BuildContext context, Widget child) {
        return Transform.translate(
          offset: Offset(
              0.0, 10 * (0.5 - _planeTween.transform(_planeController.value))),
          child: child,
        );
      },
    );

    final cloud = AnimatedBuilder(
      animation: _cloudsController,
      builder: (BuildContext context, Widget child) {
        return Transform.translate(
          offset: Offset(
              -162.0 +
                  ((MediaQuery.of(context).size.width +  162.0) * _cloudsController.value ),
              0.0),
          child: Image.asset(
            "assets/plane_indicator/cloud2.png",
            width: 162,
            height: 75,
            fit: BoxFit.contain,
          ),
        );
      },
    );
    return AnimatedBuilder(
      animation: widget.data,
      child: widget.child,
      builder: (context, child) {
        if (_prevState == IndicatorState.armed &&
            widget.data.state == IndicatorState.loading) {
          _startPlaneAnimation();
        } else if (_prevState == IndicatorState.loading &&
            widget.data.state == IndicatorState.hiding) {
          _stopPlaneAnimation();
        }
        _prevState = widget.data.state;

        return Stack(
          overflow: Overflow.clip,
          children: <Widget>[
            if (_prevState != IndicatorState.idle)
              Container(
                height: 163 * widget.data.value.clamp(0.3, 1.5),
                color: Color(0xFFFDFEFF),
                width: double.infinity,
                child: Stack(
                  overflow: Overflow.clip,
                  children: <Widget>[
                    cloud,

                    // Image.asset(
                    //   "assets/plane_indicator/cloud6.png",
                    //   width: 114,
                    //   height: 55,
                    //   fit: BoxFit.contain,
                    // ),
                    // Image.asset(
                    //   "assets/plane_indicator/cloud3.png",
                    //   width: 162,
                    //   height: 80,
                    //   fit: BoxFit.contain,
                    // ),

                    /// plane
                    Center(
                      child: plane,
                    ),
                    // Image.asset(
                    //   "assets/plane_indicator/cloud4.png",
                    //   width: 150,
                    //   height: 69,
                    //   fit: BoxFit.contain,
                    // ),
                    // Image.asset(
                    //   "assets/plane_indicator/cloud5.png",
                    //   width: 162,
                    //   height: 80,
                    //   fit: BoxFit.contain,
                    // ),
                    // Image.asset(
                    //   "assets/plane_indicator/cloud1.png",
                    //   width: 86,
                    //   height: 32,
                    //   fit: BoxFit.contain,
                    // ),
                  ],
                ),
              ),
            Transform.translate(
              offset: Offset(0.0, 163 * widget.data.value),
              child: child,
            ),
          ],
        );
      },
    );
  }
}

CustomIndicatorConfig planeIndicator = CustomIndicatorConfig(
  childTransformBuilder: (context, child, data) => PlaneIndicator(child, data),
);
