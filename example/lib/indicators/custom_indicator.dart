import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class CustomIndicatorConfig {
  final IndicatorBuilder indicatorBuilder;
  final ChildTransformBuilder childTransformBuilder;

  const CustomIndicatorConfig({
    this.indicatorBuilder,
    this.childTransformBuilder,
  });
}
