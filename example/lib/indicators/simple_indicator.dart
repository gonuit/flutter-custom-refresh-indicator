import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SimpleIndicator extends StatelessWidget {
  final CustomRefreshIndicatorData data;

  SimpleIndicator({
    @required this.data,
  });

  @override
  Widget build(BuildContext context) {
    print(data.indicatorState);

    final positionFromSide = -50 + (data.value * 120);
    final isArmed = data.isArmed;

    return Positioned(
      top: data.direction == AxisDirection.down ? positionFromSide : null,
      bottom: data.direction == AxisDirection.up ? positionFromSide : null,
      left: data.direction == AxisDirection.right ? positionFromSide : null,
      right: data.direction == AxisDirection.left ? positionFromSide : null,
      child: Container(
        height: data.isHorizontalDirection
            ? MediaQuery.of(context).size.height
            : null,
        width:
            data.isVerticalDirection ? MediaQuery.of(context).size.width : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 50,
          width: 50,
          constraints: const BoxConstraints(maxWidth: 50),
          decoration: BoxDecoration(
              color: isArmed ? Colors.black : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)]),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 50),
            child: Container(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  value: !data.loading ? data.value : null,
                  valueColor: AlwaysStoppedAnimation(
                    isArmed ? Colors.white : Colors.black,
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
