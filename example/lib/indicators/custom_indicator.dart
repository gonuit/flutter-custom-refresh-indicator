import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';

class CustomIndicatorConfig {
  final ChildTransformBuilder builder;

  const CustomIndicatorConfig({
    @required this.builder,
  }) : assert(builder != null, 'builder argument cannot be null');
}
