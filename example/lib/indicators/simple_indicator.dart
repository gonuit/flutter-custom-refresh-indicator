import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/utils/infinite_rotation.dart';
import 'package:flutter/material.dart';

class SimpleIndicatorContent extends StatelessWidget {
  const SimpleIndicatorContent({
    @required this.data,
  });

  final CustomRefreshIndicatorData data;

  @override
  Widget build(BuildContext context) {
    final isLoading = data.isLoading;
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          InfiniteRatation(
            running: isLoading,
            child: Icon(
              Icons.ac_unit,
              color: Colors.blueAccent,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
