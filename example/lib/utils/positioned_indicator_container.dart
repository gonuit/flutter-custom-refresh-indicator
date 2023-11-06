import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class PositionedIndicatorContainer extends StatelessWidget {
  final IndicatorController controller;
  final Widget child;

  /// Position child widget in a similar way
  /// to the built-in [RefreshIndicator] widget.
  const PositionedIndicatorContainer({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.side.isNone) return const SizedBox();

    final double positionFromSide = -50 + (controller.value * 110);

    final verticalSide = controller.side.isTop || controller.side.isBottom;
    final horizontalSide = controller.side.isLeft || controller.side.isRight;

    return Positioned(
      top: horizontalSide
          ? 0
          : controller.side.isTop
              ? positionFromSide
              : null,
      bottom: horizontalSide
          ? 0
          : controller.side.isBottom
              ? positionFromSide
              : null,
      left: verticalSide
          ? 0
          : controller.side.isLeft
              ? positionFromSide
              : null,
      right: verticalSide
          ? 0
          : controller.side.isRight
              ? positionFromSide
              : null,
      child: child,
    );
  }
}
