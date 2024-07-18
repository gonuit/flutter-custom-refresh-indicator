import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CheckMarkColors {
  final Color content;
  final Color background;

  const CheckMarkColors({
    required this.content,
    required this.background,
  });
}

class CheckMarkStyle {
  final CheckMarkColors loading;
  final CheckMarkColors success;
  final CheckMarkColors error;

  const CheckMarkStyle({
    required this.loading,
    required this.success,
    required this.error,
  });

  static const defaultStyle = CheckMarkStyle(
    loading: CheckMarkColors(
      content: Colors.white,
      background: Colors.blueAccent,
    ),
    success: CheckMarkColors(
      content: Colors.black,
      background: Colors.greenAccent,
    ),
    error: CheckMarkColors(
      content: Colors.black,
      background: Colors.redAccent,
    ),
  );
}

class CheckMarkIndicator extends StatefulWidget {
  final Widget child;
  final CheckMarkStyle style;
  final AsyncCallback onRefresh;
  final IndicatorController? controller;

  const CheckMarkIndicator({
    super.key,
    required this.child,
    this.controller,
    this.style = CheckMarkStyle.defaultStyle,
    required this.onRefresh,
  });

  @override
  State<CheckMarkIndicator> createState() => _CheckMarkIndicatorState();
}

class _CheckMarkIndicatorState extends State<CheckMarkIndicator>
    with SingleTickerProviderStateMixin {
  /// Whether to render check mark instead of spinner
  bool _renderCompleteState = false;

  ScrollDirection prevScrollDirection = ScrollDirection.idle;

  bool _hasError = false;

  Future<void> _handleRefresh() async {
    try {
      setState(() {
        _hasError = false;
      });
      await widget.onRefresh();
    } catch (_) {
      setState(() {
        _hasError = true;
      });
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomMaterialIndicator(
      controller: widget.controller,
      onRefresh: _handleRefresh,
      durations: const RefreshIndicatorDurations(
        completeDuration: Duration(seconds: 2),
      ),
      onStateChanged: (change) {
        /// set [_renderCompleteState] to true when controller.state become completed
        if (change.didChange(to: IndicatorState.complete)) {
          _renderCompleteState = true;

          /// set [_renderCompleteState] to false when controller.state become idle
        } else if (change.didChange(to: IndicatorState.idle)) {
          _renderCompleteState = false;
        }
      },
      indicatorBuilder: (
        BuildContext context,
        IndicatorController controller,
      ) {
        final CheckMarkColors style;
        if (_renderCompleteState) {
          if (_hasError) {
            style = widget.style.error;
          } else {
            style = widget.style.success;
          }
        } else {
          style = widget.style.loading;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: style.background,
            shape: BoxShape.circle,
          ),
          child: _renderCompleteState
              ? Icon(
                  _hasError ? Icons.close : Icons.check,
                  color: style.content,
                )
              : SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: style.content,
                    value: controller.isDragging || controller.isArmed
                        ? controller.value.clamp(0.0, 1.0)
                        : null,
                  ),
                ),
        );
      },
      child: widget.child,
    );
  }
}
