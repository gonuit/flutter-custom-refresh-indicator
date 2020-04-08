import 'package:confetti/confetti.dart';
import 'package:example/utils/infinite_rotation.dart';
import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

import 'custom_indicator.dart';

class ConfettiLayer extends StatefulWidget {
  final IndicatorData data;
  final Widget child;

  const ConfettiLayer({Key key, this.data, this.child}) : super(key: key);
  @override
  _ConfettiLayerState createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<ConfettiLayer> {
  ConfettiController _controller;
  bool _loading = false;

  @override
  void initState() {
    _controller = ConfettiController(duration: Duration(milliseconds: 500));
    widget.data.addListener(onDataChange);
    super.initState();
  }

  void onDataChange() {
    if (_loading != widget.data.isLoading) {
      _loading = widget.data.isLoading;

      if (_loading) {
        print("PLAY");
        _controller.play();
      } else {
        print("STOP");
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConfettiWidget(
        confettiController: _controller,
        blastDirectionality: BlastDirectionality.explosive,
        child: widget.child,
        shouldLoop: true,
        numberOfParticles: 100,
      ),
    );
  }
}

final emojiIndicator = CustomIndicator(
  indicatorBuilder: (context, data) => PositionedIndicatorContainer(
    data: data,
    child: AnimatedBuilder(
      animation: data,
      child: Text(
        "🤣",
        style: TextStyle(
          fontSize: 40,
        ),
        textAlign: TextAlign.center,
      ),
      builder: (context, child) =>
          InfiniteRatation(child: child, running: data.isLoading),
    ),
  ),
  childTransformBuilder: (context, child, data) => Stack(
    children: <Widget>[
      child,
      Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: SizedBox(
          height: 40,
          width: 40,
          child: ConfettiLayer(
            data: data,
          ),
        ),
      ),
    ],
  ),
);
