part of custom_refresh_indicator;

class PositionedIndicatorContainer extends StatelessWidget {
  final IndicatorData data;
  final Widget child;

  /// Position child widget in a similar way to RefreshIndicator widget
  const PositionedIndicatorContainer({
    @required this.data,
    @required this.child,
  }) : assert(child != null, "child argument cannot be null");

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: child,
      animation: data,
      builder: (BuildContext context, Widget child) {
        final double positionFromSide = -50 + (data.value * 110);

        return Positioned(
          top: data.direction == AxisDirection.down ? positionFromSide : null,
          bottom: data.direction == AxisDirection.up ? positionFromSide : null,
          left: data.direction == AxisDirection.right ? positionFromSide : null,
          right: data.direction == AxisDirection.left ? positionFromSide : null,
          child: Container(
            height: data.isHorizontalDirection
                ? MediaQuery.of(context).size.height
                : null,
            width: data.isVerticalDirection
                ? MediaQuery.of(context).size.width
                : null,
            child: child,
          ),
        );
      },
    );
  }
}
