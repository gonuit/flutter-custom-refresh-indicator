import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../custom_refresh_indicator.dart';

typedef CustomIndicatorBuilder = Widget Function(
  BuildContext context,
  CustomRefreshIndicatorData data,
);

class CustomRefreshIndicatorData {
  final bool loading;
  final bool ready;
  final double value;
  final AxisDirection direction;
  final ScrollDirection scrollingDirection;
  final CustomRefreshIndicatorState indicatorState;

  CustomRefreshIndicatorData({
    @required this.loading,
    @required this.ready,
    @required this.value,
    @required this.direction,
    @required this.scrollingDirection,
    @required this.indicatorState,
  });
}
