part of custom_refresh_indicator;

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
