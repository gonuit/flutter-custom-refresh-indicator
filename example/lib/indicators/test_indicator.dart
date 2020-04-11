import 'package:flutter/material.dart';

import 'custom_indicator.dart';

final testIndicator = CustomIndicatorConfig(
  builder: (context, child, controller) => Stack(children: <Widget>[
    Container(
      height: 200,
      width: double.infinity,
      color: Colors.green,
    ),
    Container(
      height: 150,
      width: double.infinity,
      color: Colors.blue,
    ),
    Container(
      height: 100,
      width: double.infinity,
      color: Colors.red,
    ),
    AnimatedBuilder(
      child: child,
      animation: controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, controller.value * 100),
        child: child,
      ),
    ),
  ]),
);
