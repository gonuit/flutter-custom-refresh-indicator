import 'dart:ui';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/utils/infinite_rotation.dart';
import 'package:flutter/material.dart';

class BlurIndicator extends StatelessWidget {
  final CustomRefreshIndicatorData data;

  BlurIndicator({
    @required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final opacity = (data.value - 0.5).clamp(0, 1) / 1;
      final isLoading = data.isLoading;
      return BackdropFilter(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: 35),
            child: Opacity(
              opacity: data.isLoading ? 1 : opacity,
              child: Transform.scale(
                scale: data.value,
                child: InfiniteRatation(
                  running: isLoading,
                  child: Icon(
                    Icons.refresh,
                    size: 50,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        filter:
            ImageFilter.blur(sigmaX: data.value * 5, sigmaY: data.value * 5),
      );
    });
  }
}
