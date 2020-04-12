part of custom_refresh_indicator;

typedef IndicatorBuilder = Widget Function(
  BuildContext context,
  Widget child,
  IndicatorController controller,
);

class CustomRefreshIndicator extends StatefulWidget {
  static const armedFromValue = 1.0;
  static const defaultExtentPercentageToArmed = 0.20;

  /// Duration of changing [IndicatorController] value from `<1.0` to `0.0`.
  /// When user stop dragging list before it become to armed [IndicatorState].
  final Duration draggingToIdleDuration;

  /// Duration of changing [IndicatorController] value from `<=1.5` to `1.0`.
  /// Will start just before [onRefresh] function invocation.
  final Duration armedToLoadingDuration;

  /// Duration of changing [IndicatorController] value from `1.0` to `0.0`
  /// when [onRefresh] callback was completed.
  final Duration loadingToIdleDuration;

  /// Whether to display leading glow
  final bool leadingGlowVisible;

  /// Whether to display trailing glow
  final bool trailingGlowVisible;

  /// Number of pixels that user should drag to change [IndicatorState] from idle to armed.
  final double offsetToArmed;

  /// Value from 0.0 to 1.0 that describes the percentage of scroll container extent
  /// that user should drag to change [IndicatorState] from idle to armed.
  final double extentPercentageToArmed;

  /// Part of widget tree that contains scrollable element (like ListView).
  /// Scroll notifications from the first scrollable element will be used
  /// to calculate [IndicatorController] data.
  final Widget child;

  /// Function in wich custom refresh indicator should be implemented.
  ///
  /// IMPORTANT:
  /// IT IS NOT CALLED ON EVERY [IndicatorController] DATA CHANGE.
  ///
  /// TIP:
  /// To rebuild widget on every [IndicatorController] data change, consider
  /// using [IndicatorController] that is passed to this function as the third argument
  /// in combination with [AnimationBuilder].
  final IndicatorBuilder builder;

  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh.
  /// The returned [Future] must complete when the refresh operation is finished.
  final RefreshCallback onRefresh;

  /// Indicator controller keeps all thata related to refresh indicator.
  /// It extends [ChangeNotifier] so that it could be listen for changes.
  ///
  /// TIP:
  /// Consider using it in combination with [AnimationBuilder] as animation argument
  ///
  /// The indicator controller will be passed as the third argument to the [builder] method.
  ///
  /// To better understand this data, look at example app.
  final IndicatorController controller;

  CustomRefreshIndicator({
    Key key,
    @required this.child,
    @required this.onRefresh,
    @required this.builder,
    this.controller,
    this.offsetToArmed,
    this.extentPercentageToArmed = defaultExtentPercentageToArmed,
    this.draggingToIdleDuration = const Duration(milliseconds: 300),
    this.armedToLoadingDuration = const Duration(milliseconds: 200),
    this.loadingToIdleDuration = const Duration(milliseconds: 100),
    this.leadingGlowVisible = false,
    this.trailingGlowVisible = true,
  })  : assert(child != null, 'child argument cannot be null'),
        assert(builder != null, 'builder argument cannot be null'),
        super(key: key);

  @override
  _CustomRefreshIndicatorState createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  bool __canStart = false;

  /// Whether custom refresh indicator can change [IndicatorState] from `idle` to `dragging`
  bool get _canStart =>
      __canStart && _customRefreshIndicatorController._refreshEnabled;
  set _canStart(bool canStart) {
    __canStart = canStart;
  }

  double _dragOffset;

  AnimationController _animationController;
  IndicatorController _customRefreshIndicatorController;

  /// Current [IndicatorController]
  IndicatorController get controller => _customRefreshIndicatorController;

  static const double _kPositionLimit = 1.5;
  static const double _kInitialValue = 0.0;

  @override
  void initState() {
    _dragOffset = 0;
    _canStart = false;

    _customRefreshIndicatorController =
        widget.controller ?? IndicatorController._();

    _animationController = AnimationController(
      vsync: this,
      upperBound: _kPositionLimit,
      lowerBound: _kInitialValue,
      value: _kInitialValue,
    )..addListener(_updateCustomRefreshIndicatorValue);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customRefreshIndicatorController.dispose();
    super.dispose();
  }

  /// Notifies the listeners of the controller
  void _updateCustomRefreshIndicatorValue() {
    _customRefreshIndicatorController._setValue(
      _animationController?.value ?? _kInitialValue,
    );
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0) return false;
    if (notification.leading) {
      if (!widget.leadingGlowVisible) notification.disallowGlow();
    } else {
      if (!widget.trailingGlowVisible) notification.disallowGlow();
    }
    return true;
  }

  bool _handleScrollStartNotification(ScrollStartNotification notification) {
    _canStart = notification.metrics.extentBefore == 0 &&
        controller.state == IndicatorState.idle;

    if (_canStart) controller._setIndicatorState(IndicatorState.dragging);

    controller._setAxisDirection(notification.metrics.axisDirection);
    return false;
  }

  bool _handleScrollUpdateNotification(ScrollUpdateNotification notification) {
    /// hide when list starts to scroll
    if (controller.state == IndicatorState.dragging ||
        controller.state == IndicatorState.armed) {
      if (notification.metrics.extentBefore > 0.0) {
        _hide();
      } else {
        _dragOffset -= notification.scrollDelta;
        _calculateDragOffset(notification.metrics.viewportDimension);
      }
      if (controller.state == IndicatorState.armed &&
          notification.dragDetails == null) {
        _start();
      }
    }
    return false;
  }

  bool _handleOverscrollNotification(OverscrollNotification notification) {
    _dragOffset -= notification.overscroll;
    _calculateDragOffset(notification.metrics.viewportDimension);
    return false;
  }

  bool _handleScrollEndNotification(ScrollEndNotification notification) {
    if (_animationController.value >= CustomRefreshIndicator.armedFromValue) {
      if (controller.state == IndicatorState.armed) {
        _start();
      }
    } else {
      _hide();
    }
    return false;
  }

  bool _handleUserScrollNotification(UserScrollNotification notification) {
    controller._setScrollingDirection(notification.direction);
    return false;
  }

  void _calculateDragOffset(double containerExtent) {
    if (controller.state == IndicatorState.hiding ||
        controller.state == IndicatorState.loading) return;

    double newValue;

    /// If [offestToArmed] is provided then it will be used otherwise
    /// [extentPercentageToArmed]
    if (widget.offsetToArmed != null) {
      newValue = _dragOffset / widget.offsetToArmed;
    } else {
      newValue =
          _dragOffset / (containerExtent * widget.extentPercentageToArmed);
    }

    if (newValue >= CustomRefreshIndicator.armedFromValue) {
      controller._setIndicatorState(IndicatorState.armed);
    } else if (newValue > 0.0) {
      controller._setIndicatorState(IndicatorState.dragging);
    }

    /// triggers indicator update
    _animationController.value = newValue.clamp(0.0, _kPositionLimit);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification)
      return _handleScrollStartNotification(notification);
    if (!_canStart) return false;
    if (notification is ScrollUpdateNotification)
      return _handleScrollUpdateNotification(notification);
    if (notification is OverscrollNotification)
      return _handleOverscrollNotification(notification);
    if (notification is ScrollEndNotification)
      return _handleScrollEndNotification(notification);
    if (notification is UserScrollNotification)
      return _handleUserScrollNotification(notification);

    return false;
  }

  void _start() async {
    _dragOffset = 0;

    controller._setIndicatorState(IndicatorState.loading);
    await _animationController.animateTo(1.0,
        duration: widget.armedToLoadingDuration);
    await widget.onRefresh();

    if (!mounted) return;
    controller._setIndicatorState(IndicatorState.hiding);
    await _animationController.animateTo(0.0,
        duration: widget.loadingToIdleDuration);

    if (!mounted) return;

    controller._setIndicatorState(IndicatorState.idle);
  }

  void _hide() async {
    controller._setIndicatorState(IndicatorState.hiding);
    _dragOffset = 0;
    _canStart = false;
    await _animationController.animateTo(
      0.0,
      duration: widget.draggingToIdleDuration,
      curve: Curves.ease,
    );

    if (!mounted) return;

    controller._setIndicatorState(IndicatorState.idle);
  }

  @override
  Widget build(BuildContext context) => widget.builder.call(
        context,
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: _handleGlowNotification,
            child: widget.child,
          ),
        ),
        controller,
      );
}
