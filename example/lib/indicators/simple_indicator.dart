import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/utils/infinite_rotation.dart';
import 'package:example/utils/positioned_indicator_container.dart';
import 'package:flutter/material.dart';

import 'custom_indicator.dart';

class SimpleIndicatorContent extends StatelessWidget {
  const SimpleIndicatorContent({
    Key? key,
    required this.controller,
    this.indicatorSize = _defaultIndicatorSize,
  })  : assert(indicatorSize > 0),
        super(key: key);

  final IndicatorController controller;
  static const _defaultIndicatorSize = 40.0;
  final double indicatorSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: indicatorSize,
      width: indicatorSize,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(blurRadius: 5, color: Color(0x42000000))],
      ),
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: controller,
              child: const Icon(
                Icons.refresh,
                color: Colors.blueAccent,
                size: 30,
              ),
              builder: (context, child) => InfiniteRatation(
                running: controller.isLoading,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final simpleIndicator = CustomIndicatorConfig(
  builder: (context, child, controller) =>
      LayoutBuilder(builder: (context, constraints) {
    return Stack(
      children: <Widget>[
        child,
        PositionedIndicatorContainer(
          constraints: constraints,
          controller: controller,
          child: SimpleIndicatorContent(
            controller: controller,
          ),
        ),
      ],
    );
  }),
);

final simpleIndicatorWithOpacity = CustomIndicatorConfig(
  builder: (context, child, controller) =>
      LayoutBuilder(builder: (context, constraints) {
    return Stack(children: <Widget>[
      Opacity(
        opacity: 1.0 - controller.value.clamp(0.0, 1.0),
        child: child,
      ),
      PositionedIndicatorContainer(
        constraints: constraints,
        controller: controller,
        child: SimpleIndicatorContent(controller: controller),
      ),
    ]);
  }),
);
