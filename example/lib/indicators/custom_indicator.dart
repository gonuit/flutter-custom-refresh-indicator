import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class CustomIndicator {
  final IndicatorBuilder indicatorBuilder;
  final ChildTransformBuilder childTransformBuilder;

  const CustomIndicator({
    this.indicatorBuilder,
    this.childTransformBuilder,
  });
}
