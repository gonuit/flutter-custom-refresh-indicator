import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A function type that builds a material-style indicator widget.
///
/// This builder takes the current [BuildContext] and an [IndicatorController]
/// to construct the widget.
typedef MaterialIndicatorBuilder = Widget Function(
  BuildContext context,
  IndicatorController controller,
);

class CustomMaterialIndicator extends StatelessWidget {
  /// {@macro custom_refresh_indicator.child}
  final Widget child;

  /// {@macro custom_refresh_indicator.auto_rebuild}
  final bool autoRebuild;

  /// {@macro custom_refresh_indicator.on_refresh}
  final AsyncCallback onRefresh;

  /// The distance from the child's top or bottom [edgeOffset] where
  /// the refresh indicator will settle. During the drag that exposes the refresh
  /// indicator, its actual displacement may significantly exceed this value.
  ///
  /// In most cases, [displacement] distance starts counting from the parent's
  /// edges. However, if [edgeOffset] is larger than zero then the [displacement]
  /// value is calculated from that offset instead of the parent's edge.
  final double displacement;

  /// The offset where indicator starts to appear on drag start.
  ///
  /// Depending whether the indicator is showing on the top or bottom, the value
  /// of this variable controls how far from the parent's edge the progress
  /// indicator starts to appear. This may come in handy when, for example, the
  /// UI contains a top [Widget] which covers the parent's edge where the progress
  /// indicator would otherwise appear.
  ///
  /// By default, the edge offset is set to 0.
  final double edgeOffset;

  /// The indicator background color
  final Color? backgroundColor;

  /// The z-coordinate at which to place this material relative to its parent.
  ///
  /// This controls the size of the shadow below the material and
  /// the opacity of the elevation overlay color if it is applied.
  ///
  /// Defaults to `2.0`.
  final double elevation;

  /// Builds the content for the indicator container
  final MaterialIndicatorBuilder indicatorBuilder;

  /// A builder that constructs a scrollable widget, typically used for a list.
  ///
  /// This builder is responsible for building the scrollable widget ([child])
  /// that can be animated during loading or other state changes.
  final IndicatorBuilder scrollableBuilder;

  /// When set to *true*, the indicator will rotate
  /// in the [IndicatorState.loading] state.
  final bool withRotation;

  /// {@macro custom_refresh_indicator.notification_predicate}
  final ScrollNotificationPredicate notificationPredicate;

  /// The content will be clipped (or not) according to this option.
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// {@macro custom_refresh_indicator.indicator_trigger}
  ///
  /// {@macro custom_refresh_indicator.trigger}
  final IndicatorTrigger trigger;

  /// {@macro custom_refresh_indicator.trigger_mode}
  final IndicatorTriggerMode triggerMode;

  /// {@macro custom_refresh_indicator.controller}
  final IndicatorController? controller;

  /// {@macro custom_refresh_indicator.durations}
  final RefreshIndicatorDurations durations;

  /// {@macro custom_refresh_indicator.on_state_changed}
  final OnStateChanged? onStateChanged;

  /// Whether to display leading scroll indicator
  final bool leadingScrollIndicatorVisible;

  /// Whether to display trailing scroll indicator
  final bool trailingScrollIndicatorVisible;

  const CustomMaterialIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    required this.indicatorBuilder,
    this.scrollableBuilder = _defaultBuilder,
    this.notificationPredicate = CustomRefreshIndicator.defaultScrollNotificationPredicate,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.withRotation = true,
    this.elevation = 2.0,
    this.clipBehavior = Clip.none,
    this.autoRebuild = true,
    this.trigger = IndicatorTrigger.leadingEdge,
    this.triggerMode = IndicatorTriggerMode.onEdge,
    this.controller,
    this.durations = const RefreshIndicatorDurations(),
    this.onStateChanged,
    this.leadingScrollIndicatorVisible = false,
    this.trailingScrollIndicatorVisible = true,
  }) : super(key: key);

  static Widget _defaultBuilder(BuildContext context, Widget child, IndicatorController controller) => child;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      autoRebuild: false,
      notificationPredicate: notificationPredicate,
      onRefresh: onRefresh,
      trigger: trigger,
      triggerMode: triggerMode,
      controller: controller,
      durations: durations,
      onStateChanged: onStateChanged,
      trailingScrollIndicatorVisible: trailingScrollIndicatorVisible,
      leadingScrollIndicatorVisible: leadingScrollIndicatorVisible,
      builder: (context, child, controller) {
        final Color backgroundColor = this.backgroundColor ??
            ProgressIndicatorTheme.of(context).refreshBackgroundColor ??
            Theme.of(context).canvasColor;

        return Stack(
          children: <Widget>[
            scrollableBuilder(context, child, controller),
            _PositionedIndicatorContainer(
              edgeOffset: edgeOffset,
              displacement: displacement,
              controller: controller,
              child: ScaleTransition(
                scale: controller.isFinalizing ? controller.clamp(0.0, 1.0) : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 41,
                  height: 41,
                  margin: const EdgeInsets.all(4.0),
                  child: Material(
                    type: MaterialType.circle,
                    clipBehavior: clipBehavior,
                    color: backgroundColor,
                    elevation: elevation,
                    child: _InfiniteRotation(
                      running: withRotation && controller.isLoading,
                      child: autoRebuild
                          ? AnimatedBuilder(
                              animation: controller,
                              builder: (context, _) => indicatorBuilder(context, controller),
                            )
                          : indicatorBuilder(context, controller),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

class _PositionedIndicatorContainer extends StatelessWidget {
  final IndicatorController controller;
  final double displacement;
  final Widget child;
  final double edgeOffset;

  /// Position child widget in a similar way
  /// to the built-in [RefreshIndicator] widget.
  const _PositionedIndicatorContainer({
    Key? key,
    required this.child,
    required this.controller,
    required this.displacement,
    required this.edgeOffset,
  }) : super(key: key);

  Alignment _getAlignement(IndicatorSide side) {
    switch (side) {
      case IndicatorSide.left:
        return Alignment.centerLeft;
      case IndicatorSide.top:
        return Alignment.topCenter;
      case IndicatorSide.right:
        return Alignment.centerRight;
      case IndicatorSide.bottom:
        return Alignment.bottomCenter;
      case IndicatorSide.none:
        throw UnsupportedError('Cannot get alignement for "none" side.');
    }
  }

  EdgeInsets _getEdgeInsets(IndicatorSide side) {
    switch (side) {
      case IndicatorSide.left:
        return EdgeInsets.only(left: displacement);
      case IndicatorSide.top:
        return EdgeInsets.only(top: displacement);
      case IndicatorSide.right:
        return EdgeInsets.only(right: displacement);
      case IndicatorSide.bottom:
        return EdgeInsets.only(bottom: displacement);
      case IndicatorSide.none:
        throw UnsupportedError('Cannot get edge insets for "none" side.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final side = controller.side;
    if (side.isNone) return const SizedBox.shrink();

    final isVerticalAxis = side.isTop || side.isBottom;
    final isHorizontalAxis = side.isLeft || side.isRight;

    final AlignmentDirectional alignment = isVerticalAxis
        ? AlignmentDirectional(-1.0, side.isTop ? 1.0 : -1.0)
        : AlignmentDirectional(side.isLeft ? 1.0 : -1.0, -1.0);

    final endOffset = isVerticalAxis ? Offset(0.0, side.isTop ? 1.0 : -1.0) : Offset(side.isLeft ? 1.0 : -1.0, 0.0);

    final animation = controller.isFinalizing
        ? AlwaysStoppedAnimation(endOffset)
        : Tween(begin: const Offset(0.0, 0.0), end: endOffset).animate(controller);

    return Positioned(
      top: isHorizontalAxis
          ? 0
          : side.isTop
              ? edgeOffset
              : null,
      bottom: isHorizontalAxis
          ? 0
          : side.isBottom
              ? edgeOffset
              : null,
      left: isVerticalAxis
          ? 0
          : side.isLeft
              ? edgeOffset
              : null,
      right: isVerticalAxis
          ? 0
          : side.isRight
              ? edgeOffset
              : null,
      child: Align(
        alignment: alignment,
        heightFactor: isVerticalAxis ? 0.0 : null,
        widthFactor: isHorizontalAxis ? 0.0 : null,
        child: SlideTransition(
          position: animation,
          child: Padding(
            padding: _getEdgeInsets(side),
            child: Align(
              alignment: _getAlignement(side),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfiniteRotation extends StatefulWidget {
  final Widget? child;
  final bool running;

  const _InfiniteRotation({
    required this.child,
    required this.running,
    Key? key,
  }) : super(key: key);
  @override
  _InfiniteRotationState createState() => _InfiniteRotationState();
}

class _InfiniteRotationState extends State<_InfiniteRotation> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void didUpdateWidget(_InfiniteRotation oldWidget) {
    if (oldWidget.running != widget.running) {
      if (widget.running) {
        _startAnimation();
      } else {
        _rotationController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 50),
        );
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    if (widget.running) {
      _startAnimation();
    }

    super.initState();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _rotationController.repeat();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(turns: _rotationController, child: widget.child);
}
