import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class PositionedIndicatorContainer extends StatelessWidget {
  final IndicatorController controller;
  final Widget child;
  final BoxConstraints? constraints;

  /// Position child widget in a similar way to RefreshIndicator widget
  const PositionedIndicatorContainer({
    Key? key,
    required this.controller,
    required this.constraints,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        if (controller.side.isNone) return const SizedBox();

        final double positionFromSide = -50 + (controller.value * 110);

        return Positioned(
          top: controller.side.isTop ? positionFromSide : null,
          bottom: controller.side.isBottom ? positionFromSide : null,
          left: controller.side.isLeft ? positionFromSide : null,
          right: controller.side.isRight ? positionFromSide : null,
          child: LayoutBuilder(
            builder: (ctx, cons) {
              return SizedBox(
                height: controller.isHorizontalDirection
                    ? constraints?.maxHeight ??
                        MediaQuery.of(context).size.height
                    : null,
                width: controller.isVerticalDirection
                    ? constraints?.maxWidth ?? MediaQuery.of(context).size.width
                    : null,
                child: child,
              );
            },
          ),
        );
      },
      child: child,
    );
  }
}
