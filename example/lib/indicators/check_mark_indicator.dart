import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CheckMarkIndicator extends StatefulWidget {
  final Widget child;

  const CheckMarkIndicator({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _CheckMarkIndicatorState createState() => _CheckMarkIndicatorState();
}

class _CheckMarkIndicatorState extends State<CheckMarkIndicator>
    with SingleTickerProviderStateMixin {
  static const _indicatorSize = 150.0;
  static const _imageSize = 140.0;

  IndicatorState _prevState;
  AnimationController _spoonController;

  @override
  void initState() {
    _spoonController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    super.initState();
  }

  bool _renderCompleteState = false;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      offsetToArmed: _indicatorSize,
      onRefresh: () => Future.delayed(const Duration(seconds: 4)),
      child: widget.child,
      completeStateDuration: const Duration(seconds: 2),
      builder: (
        BuildContext context,
        Widget child,
        IndicatorController controller,
      ) {
        return Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget _) {
                /// set [_renderCompleteState] to true when controller.state become completed
                if (controller.didStateChange(to: IndicatorState.complete)) {
                  _renderCompleteState = true;

                  /// set [_renderCompleteState] to false when controller.state become idle
                } else if (controller.didStateChange(to: IndicatorState.idle)) {
                  _renderCompleteState = false;
                }
                final height = controller.value * _indicatorSize;

                return Container(
                  alignment: Alignment.center,
                  height: height,
                  child: OverflowBox(
                    maxHeight: 40,
                    minHeight: 40,
                    maxWidth: 40,
                    minWidth: 40,
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      alignment: Alignment.center,
                      child: _renderCompleteState
                          ? Icon(Icons.check)
                          : SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                      decoration: BoxDecoration(
                        color: _renderCompleteState
                            ? Colors.greenAccent
                            : Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0.0, controller.value * _indicatorSize),
                  child: child,
                );
              },
              animation: controller,
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _spoonController.dispose();
    super.dispose();
  }
}
