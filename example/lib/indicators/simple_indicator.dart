import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/utils/infinite_rotation.dart';
import 'package:flutter/material.dart';

import 'custom_indicator.dart';

class SimpleIndicatorContent extends StatelessWidget {
  const SimpleIndicatorContent({
    @required this.data,
    this.indicatorSize = _defaultIndicatorSize,
  }) : assert(indicatorSize != null && indicatorSize > 0);

  final IndicatorData data;
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
              animation: data,
              child: const Icon(
                Icons.refresh,
                color: Colors.blueAccent,
                size: 30,
              ),
              builder: (context, child) => InfiniteRatation(
                running: data.isLoading,
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
  indicatorBuilder: (context, data) => PositionedIndicatorContainer(
    data: data,
    child: SimpleIndicatorContent(
      data: data,
    ),
  ),
);

final simpleIndicatorWithOpacity = CustomIndicatorConfig(
  childTransformBuilder: (context, child, data) => AnimatedBuilder(
    child: child,
    animation: data,
    builder: (context, child) => Opacity(
      opacity: 1.0 - data.value.clamp(0.0, 1.0),
      child: child,
    ),
  ),
  indicatorBuilder: (context, data) => PositionedIndicatorContainer(
    data: data,
    child: SimpleIndicatorContent(
      data: data,
    ),
  ),
);
