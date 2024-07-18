import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/widgets.dart';

/// Position child widget in a similar way
/// to the built-in [RefreshIndicator] widget.
class PositionedIndicatorContainer extends StatelessWidget {
  final IndicatorController controller;
  final double displacement;
  final Widget child;
  final double edgeOffset;

  /// Position child widget in a similar way
  /// to the built-in [RefreshIndicator] widget.
  const PositionedIndicatorContainer({
    super.key,
    required this.child,
    required this.controller,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
  });

  Alignment _getAlignment(IndicatorSide side) {
    switch (side) {
      case IndicatorSide.left:
        return Alignment.centerLeft;
      case IndicatorSide.top:
        return Alignment.topCenter;
      case IndicatorSide.right:
        return Alignment.centerRight;
      case IndicatorSide.bottom:
        return Alignment.bottomCenter;
      case IndicatorSide.none:
        throw UnsupportedError('Cannot get alignment for "none" side.');
    }
  }

  EdgeInsets _getEdgeInsets(IndicatorSide side) {
    switch (side) {
      case IndicatorSide.left:
        return EdgeInsets.only(left: displacement);
      case IndicatorSide.top:
        return EdgeInsets.only(top: displacement);
      case IndicatorSide.right:
        return EdgeInsets.only(right: displacement);
      case IndicatorSide.bottom:
        return EdgeInsets.only(bottom: displacement);
      case IndicatorSide.none:
        throw UnsupportedError('Cannot get edge insets for "none" side.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final side = controller.side;
    if (side.isNone) return const SizedBox.shrink();

    final isVerticalAxis = side.isTop || side.isBottom;
    final isHorizontalAxis = side.isLeft || side.isRight;

    final AlignmentDirectional alignment = isVerticalAxis
        ? AlignmentDirectional(-1.0, side.isTop ? 1.0 : -1.0)
        : AlignmentDirectional(side.isLeft ? 1.0 : -1.0, -1.0);

    final endOffset = isVerticalAxis
        ? Offset(0.0, side.isTop ? 1.0 : -1.0)
        : Offset(side.isLeft ? 1.0 : -1.0, 0.0);

    final animation = controller.isFinalizing
        ? AlwaysStoppedAnimation(endOffset)
        : Tween(begin: const Offset(0.0, 0.0), end: endOffset)
            .animate(controller);

    return Positioned(
      top: isHorizontalAxis
          ? 0
          : side.isTop
              ? edgeOffset
              : null,
      bottom: isHorizontalAxis
          ? 0
          : side.isBottom
              ? edgeOffset
              : null,
      left: isVerticalAxis
          ? 0
          : side.isLeft
              ? edgeOffset
              : null,
      right: isVerticalAxis
          ? 0
          : side.isRight
              ? edgeOffset
              : null,
      child: Align(
        alignment: alignment,
        heightFactor: isVerticalAxis ? 0.0 : null,
        widthFactor: isHorizontalAxis ? 0.0 : null,
        child: SlideTransition(
          position: animation,
          child: Padding(
            padding: _getEdgeInsets(side),
            child: Align(
              alignment: _getAlignment(side),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
