part of custom_refresh_indicator;

class SimpleIndicatorContainer extends StatelessWidget {
  final CustomRefreshIndicatorData data;
  final Widget child;
  final double indicatorSize;

  static const _defaultIndicatorSize = 40.0;

  const SimpleIndicatorContainer({
    @required this.data,
    @required this.child,
    this.indicatorSize = _defaultIndicatorSize,
  })  : assert(indicatorSize != null && indicatorSize > 0),
        assert(child != null);

  @override
  Widget build(BuildContext context) {
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
        width:
            data.isVerticalDirection ? MediaQuery.of(context).size.width : null,
        child: Container(
          height: indicatorSize,
          width: indicatorSize,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(blurRadius: 5, color: Color(0x42000000))],
          ),
          child: child,
        ),
      ),
    );
  }
}
