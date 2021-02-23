part of custom_refresh_indicator;

class PositionedIndicatorContainer extends StatelessWidget {
  final IndicatorController controller;
  final Widget child;

  /// Position child widget in a similar way to RefreshIndicator widget
  const PositionedIndicatorContainer({
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: child,
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final double positionFromSide = -50 + (controller.value * 110);

        return Positioned(
          top: controller.direction == AxisDirection.down
              ? positionFromSide
              : null,
          bottom: controller.direction == AxisDirection.up
              ? positionFromSide
              : null,
          left: controller.direction == AxisDirection.right
              ? positionFromSide
              : null,
          right: controller.direction == AxisDirection.left
              ? positionFromSide
              : null,
          child: Container(
            height: controller.isHorizontalDirection
                ? MediaQuery.of(context).size.height
                : null,
            width: controller.isVerticalDirection
                ? MediaQuery.of(context).size.width
                : null,
            child: child,
          ),
        );
      },
    );
  }
}
