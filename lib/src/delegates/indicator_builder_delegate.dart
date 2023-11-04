import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/widgets.dart';

/// An abstract class for defining indicator delegates.
@Deprecated(
  'Indicator delegates are deprecated and will be removed in the upcoming release. '
  'If you want to exapose some pre-built functionality wrap the CustomRefreshIndicator widget '
  'with your custom implementation.',
)
abstract class IndicatorBuilderDelegate {
  const IndicatorBuilderDelegate();

  /// When set to true, the [build] function will be called whenever the controller changes.
  /// It is set to `true` by default.
  ///
  /// This can be useful for optimizing performance in complex widgets.
  /// When setting this to false, you can manage which part of the ui you want to rebuild,
  /// such as using the AnimationBuilder widget.
  bool get autoRebuild;

  /// Function that builds the custom refresh indicator
  Widget build(
    BuildContext context,
    Widget child,
    IndicatorController controller,
  );

  Widget call(
    BuildContext context,
    Widget child,
    IndicatorController controller,
  ) =>
      build(context, child, controller);
}
