import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

import 'custom_indicator.dart';

final simpleIndicator = CustomIndicatorConfig(
  builder: MaterialIndicatorDelegate(
    builder: (context, controller) {
      return Icon(
        Icons.ac_unit,
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      );
    },
  ),
);

final simpleIndicatorWithOpacity = CustomIndicatorConfig(
  builder: MaterialIndicatorDelegate(
    builder: (context, controller) {
      return Icon(
        Icons.ac_unit,
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      );
    },
    scrollableBuilder: (context, child, controller) {
      return Opacity(
        opacity: 1.0 - controller.value.clamp(0.0, 1.0),
        child: child,
      );
    },
  ),
);
