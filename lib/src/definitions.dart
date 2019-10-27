import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef CustomIndicatorBuilder = Widget Function(
  BuildContext context,
  CustomRefreshIndicatorData data,
);

/// Describes state of CustomRefreshIndicator
enum CustomRefreshIndicatorState {
  /// Indicator should be idle
  idle,

  /// List is dragged
  draging,

  /// Indicator is dragged enough to be trigger `onRefresh` action
  armed,

  /// hiding indicator when `onRefresh` action is done or indicator was canceled
  hiding,

  /// `onRefresh` action is pending
  loading,
}

class CustomRefreshIndicatorData {
  final bool loading;
  final double value;

  CustomRefreshIndicatorData({
    @required this.loading,
    @required this.value,
    @required this.direction,
    @required this.scrollingDirection,
    @required this.indicatorState,
  });

  final ScrollDirection scrollingDirection;
  bool get isScrollingForward => scrollingDirection == ScrollDirection.forward;
  bool get isScrollingReverse => scrollingDirection == ScrollDirection.reverse;
  bool get isScrollIdle => scrollingDirection == ScrollDirection.idle;

  final AxisDirection direction;
  bool get isHorizontalDirection =>
      direction == AxisDirection.left || direction == AxisDirection.right;
  bool get isVerticalDirection =>
      direction == AxisDirection.up || direction == AxisDirection.down;

  final CustomRefreshIndicatorState indicatorState;
  bool get isArmed => indicatorState == CustomRefreshIndicatorState.armed;
  bool get isDraging => indicatorState == CustomRefreshIndicatorState.draging;
  bool get isLoading => indicatorState == CustomRefreshIndicatorState.loading;
  bool get isHiding => indicatorState == CustomRefreshIndicatorState.hiding;
  bool get isIdle => indicatorState == CustomRefreshIndicatorState.idle;
}
