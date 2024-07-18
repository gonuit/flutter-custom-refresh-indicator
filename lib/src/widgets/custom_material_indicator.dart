import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
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

/// A CustomMaterialIndicator widget that replicates
/// the behavior of the material indicator widget.
///
/// It allows for extensive customization of its appearance and behavior.
class CustomMaterialIndicator extends StatefulWidget {
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
  final MaterialIndicatorBuilder? indicatorBuilder;

  /// A builder that constructs a scrollable widget, typically used for a list.
  ///
  /// This builder is responsible for building the scrollable widget ([child])
  /// that can be animated during loading or other state changes.
  final IndicatorBuilder scrollableBuilder;

  /// {@macro custom_refresh_indicator.notification_predicate}
  final ScrollNotificationPredicate notificationPredicate;

  /// The content will be clipped (or not) according to this option.
  /// Applies only if a custom [indicatorBuilder] is provided and material indicator used.
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

  /// Defines [strokeWidth] for `RefreshIndicator`.
  ///
  /// By default, the value of [strokeWidth] is 2.5 pixels.
  final double strokeWidth;

  /// {@macro flutter.progress_indicator.ProgressIndicator.semanticsLabel}
  ///
  /// This will be defaulted to [MaterialLocalizations.refreshIndicatorSemanticLabel]
  /// if it is null.
  final String? semanticsLabel;

  /// {@macro flutter.progress_indicator.ProgressIndicator.semanticsValue}
  final String? semanticsValue;

  /// The progress indicator's foreground color. The current theme's
  /// [ColorScheme.primary] by default.
  final Color? color;

  /// when true, the appropriate indicator should be selected depending on the platform.
  final bool _isAdaptive;

  /// When true (default), the widget returned from the [indicatorBuilder] function
  /// will be wrapped in the material indicator container widget.
  ///
  /// By default true.
  final bool useMaterialContainer;

  /// The size of the indicator widget.
  ///
  /// By default 41 x 41.
  final Size indicatorSize;

  /// A default constructor that creates a CustomMaterialIndicator widget
  /// that replicates the behavior of the material indicator widget.
  const CustomMaterialIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.indicatorBuilder,
    this.scrollableBuilder = _defaultBuilder,
    this.notificationPredicate =
        CustomRefreshIndicator.defaultScrollNotificationPredicate,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
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
    double? strokeWidth,
    this.semanticsLabel,
    this.semanticsValue,
    this.color,
    this.useMaterialContainer = true,
    this.indicatorSize = defaultIndicatorSize,
  })  : assert(
          indicatorBuilder == null ||
              (color == null &&
                  semanticsValue == null &&
                  semanticsLabel == null &&
                  strokeWidth == null),
          'When a custom indicatorBuilder is provided, the parameters color, semanticsValue, semanticsLabel and strokeWidth are unused and can be safely removed.',
        ),
        strokeWidth =
            strokeWidth ?? RefreshProgressIndicator.defaultStrokeWidth,
        _isAdaptive = false;

  /// Creates a CustomMaterialIndicator widget that displays a different
  /// indicator based on the target platform.
  ///
  /// It uses [CupertinoActivityIndicator] for iOS and macOS
  /// and [RefreshProgressIndicator] for other platforms.
  const CustomMaterialIndicator.adaptive({
    super.key,
    required this.child,
    required this.onRefresh,
    this.indicatorBuilder,
    this.scrollableBuilder = _defaultBuilder,
    this.notificationPredicate =
        CustomRefreshIndicator.defaultScrollNotificationPredicate,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
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
    double? strokeWidth,
    this.semanticsLabel,
    this.semanticsValue,
    this.color,
    this.indicatorSize = defaultIndicatorSize,
  })  : assert(
          indicatorBuilder == null ||
              (color == null &&
                  semanticsValue == null &&
                  semanticsLabel == null &&
                  strokeWidth == null),
          'When a custom indicatorBuilder is provided, the parameters color, semanticsValue, semanticsLabel and strokeWidth are unused and can be safely removed.',
        ),
        useMaterialContainer = true,
        strokeWidth =
            strokeWidth ?? RefreshProgressIndicator.defaultStrokeWidth,
        _isAdaptive = true;

  static Widget _defaultBuilder(
          BuildContext context, Widget child, IndicatorController controller) =>
      child;

  static const defaultIndicatorSize = Size(41, 41);

  @override
  State<CustomMaterialIndicator> createState() =>
      _CustomMaterialIndicatorState();
}

class _CustomMaterialIndicatorState extends State<CustomMaterialIndicator> {
  IndicatorController? _internalIndicatorController;
  IndicatorController get controller =>
      widget.controller ??
      (_internalIndicatorController ??= IndicatorController());

  @override
  void didUpdateWidget(covariant CustomMaterialIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When a new background color is provided.
    if (oldWidget.backgroundColor != widget.backgroundColor) {
      _backgroundColor = _getBackgroundColor();
    }

    // When a new controller is provided externally.
    if (oldWidget.controller != widget.controller) {
      if (widget.controller != null) {
        // Dispose and remove the current internal controller, if it exists
        _internalIndicatorController?.dispose();
        _internalIndicatorController = null;
      }

      // Update animations/listeners.
      _setupMaterialIndicator();
    } else if (oldWidget.color != widget.color) {
      // Update color animation.
      _setupMaterialIndicator();
    }

    assert(
      widget.controller == null ||
          (widget.controller != null && _internalIndicatorController == null),
      'An internal indicator should not exist when an external indicator is provided.',
    );
  }

  Widget _defaultMaterialIndicatorBuilder(
      BuildContext context, IndicatorController controller) {
    final bool showIndeterminateIndicator = controller.isLoading ||
        controller.isComplete ||
        controller.isFinalizing;

    return RefreshProgressIndicator(
      semanticsLabel: widget.semanticsLabel ??
          MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      semanticsValue: widget.semanticsValue,
      value: showIndeterminateIndicator ? null : _valueAnimation.value,
      valueColor: _colorAnimation,
      backgroundColor: _backgroundColor,
      strokeWidth: widget.strokeWidth,
    );
  }

  Widget _defaultCupertinoIndicatorBuilder(
      BuildContext context, IndicatorController controller) {
    return CupertinoActivityIndicator(
      color: widget.color,
    );
  }

  late Animation<double> _valueAnimation;
  late Animation<Color?> _colorAnimation;
  late Color _indicatorColor;
  late Color _backgroundColor;

  @override
  void didChangeDependencies() {
    _setupMaterialIndicator();
    super.didChangeDependencies();
  }

  Color _getBackgroundColor() {
    return widget.backgroundColor ??
        ProgressIndicatorTheme.of(context).refreshBackgroundColor ??
        Theme.of(context).canvasColor;
  }

  Color _getIndicatorColor() {
    return widget.color ?? Theme.of(context).colorScheme.primary;
  }

  void _setupMaterialIndicator() {
    _valueAnimation = controller.normalize();
    // Reset the current color.
    _backgroundColor = _getBackgroundColor();
    _indicatorColor = _getIndicatorColor();
    final Color color = _indicatorColor;
    if (color.alpha == 0x00) {
      // Set an always stopped animation instead of a driven tween.
      _colorAnimation = AlwaysStoppedAnimation<Color>(color);
    } else {
      // Respect the alpha of the given color.
      _colorAnimation = _valueAnimation.drive(
        ColorTween(
          begin: color.withAlpha(0),
          end: color.withAlpha(color.alpha),
        ).chain(
          CurveTween(
            curve: const Interval(0.0, 1.0 / 1.5),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool useMaterial = true;
    if (widget._isAdaptive) {
      final ThemeData theme = Theme.of(context);
      switch (theme.platform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          useMaterial = true;
          break;
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          useMaterial = false;
          break;
      }
    }

    final MaterialIndicatorBuilder indicatorBuilder = widget.indicatorBuilder ??
        (useMaterial
            ? _defaultMaterialIndicatorBuilder
            : _defaultCupertinoIndicatorBuilder);

    return CustomRefreshIndicator(
      autoRebuild: false,
      notificationPredicate: widget.notificationPredicate,
      onRefresh: widget.onRefresh,
      trigger: widget.trigger,
      triggerMode: widget.triggerMode,
      controller: controller,
      durations: widget.durations,
      onStateChanged: widget.onStateChanged,
      trailingScrollIndicatorVisible: widget.trailingScrollIndicatorVisible,
      leadingScrollIndicatorVisible: widget.leadingScrollIndicatorVisible,
      builder: (context, child, controller) {
        Widget indicator = widget.autoRebuild
            ? AnimatedBuilder(
                animation: controller,
                builder: (context, _) => indicatorBuilder(context, controller),
              )
            : indicatorBuilder(context, controller);

        /// If indicatorBuilder is not provided
        if (widget.indicatorBuilder != null) {
          indicator = Container(
            width: 41,
            height: 41,
            margin: const EdgeInsets.all(4.0),
            child: useMaterial && widget.useMaterialContainer
                ? Material(
                    type: MaterialType.circle,
                    clipBehavior: widget.clipBehavior,
                    color: _backgroundColor,
                    elevation: widget.elevation,
                    child: indicator,
                  )
                : indicator,
          );
        }

        return Stack(
          children: <Widget>[
            widget.scrollableBuilder(context, child, controller),
            PositionedIndicatorContainer(
              edgeOffset: widget.edgeOffset,
              displacement: widget.displacement,
              controller: controller,
              child: ScaleTransition(
                scale: controller.isFinalizing
                    ? _valueAnimation
                    : const AlwaysStoppedAnimation(1.0),
                child: indicator,
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _internalIndicatorController?.dispose();
    super.dispose();
  }
}
