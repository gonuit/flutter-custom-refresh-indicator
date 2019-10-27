import 'package:flutter/material.dart';

import '../../definitions.dart';

class SimpleIndicatorContainer extends StatelessWidget {
  final CustomRefreshIndicatorData data;
  final Widget child;
  final indicatorSize;

  static const _defaultIndicatorSize = 40.0;

  SimpleIndicatorContainer({
    @required this.data,
    @required this.child,
    this.indicatorSize = _defaultIndicatorSize,
  })  : assert(indicatorSize != null && indicatorSize > 0),
        assert(child != null);

  @override
  Widget build(BuildContext context) {
    final positionFromSide = -50 + (data.value * 110);

    return Positioned(
      top: data.direction == AxisDirection.down ? positionFromSide : null,
      bottom: data.direction == AxisDirection.up ? positionFromSide : null,
      left: data.direction == AxisDirection.right ? positionFromSide : null,
      right: data.direction == AxisDirection.left ? positionFromSide : null,
      child: Container(
        height: data.isHorizontalDirection
            ? MediaQuery.of(context).size.height
            : null,
        width:
            data.isVerticalDirection ? MediaQuery.of(context).size.width : null,
        child: Container(
          height: indicatorSize,
          width: indicatorSize,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)]),
          child: child,
        ),
      ),
    );
  }
}
