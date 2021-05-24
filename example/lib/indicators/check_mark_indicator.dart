import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CheckMarkIndicator extends StatefulWidget {
  final Widget child;

  const CheckMarkIndicator({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _CheckMarkIndicatorState createState() => _CheckMarkIndicatorState();
}

class _CheckMarkIndicatorState extends State<CheckMarkIndicator>
    with SingleTickerProviderStateMixin {
  static const _indicatorSize = 150.0;
  final _helper = IndicatorStateHelper();

  /// Whether to render check mark instead of spinner
  bool _renderCompleteState = false;


  ScrollDirection prevScrollDirection = ScrollDirection.idle;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      offsetToArmed: _indicatorSize,
      onRefresh: () => Future.delayed(const Duration(seconds: 2)),
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
              builder: (BuildContext context, Widget? _) {
                _helper.update(controller.state);

                if (controller.scrollingDirection == ScrollDirection.reverse &&
                    prevScrollDirection == ScrollDirection.forward) {
                  controller.stopDrag();
                }

                prevScrollDirection = controller.scrollingDirection;

                /// set [_renderCompleteState] to true when controller.state become completed
                if (_helper.didStateChange(to: IndicatorState.complete)) {
                  _renderCompleteState = true;

                  /// set [_renderCompleteState] to false when controller.state become idle
                } else if (_helper.didStateChange(to: IndicatorState.idle)) {
                  _renderCompleteState = false;
                }
                final containerHeight = controller.value * _indicatorSize;

                return Container(
                  alignment: Alignment.center,
                  height: containerHeight,
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
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                                value:
                                    controller.isDragging || controller.isArmed
                                        ? controller.value.clamp(0.0, 1.0)
                                        : null,
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
}
