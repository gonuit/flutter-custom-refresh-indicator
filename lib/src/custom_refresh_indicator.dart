part of custom_refresh_indicator;

typedef RefreshCallback = Future<void> Function();

class CustomRefreshIndicator extends StatefulWidget {
  static const armedFromValue = 1.0;
  static const defaultExtentPercentageToArmed = 0.3;

  final Duration dragingToIdleDuration;
  final Duration armedToLoadingDuration;
  final Duration loadingToIdleDuration;
  final bool leadingGlowVisible;
  final bool trailingGlowVisible;
  final double offsetToArmed;
  final double extentPercentageToArmed;
  final Widget child;
  final ChildTransformBuilder builder;
  final RefreshCallback onRefresh;

  CustomRefreshIndicator({
    @required this.child,
    @required this.onRefresh,
    @required this.builder,
    this.offsetToArmed,
    this.extentPercentageToArmed = defaultExtentPercentageToArmed,
    this.dragingToIdleDuration = const Duration(milliseconds: 300),
    this.armedToLoadingDuration = const Duration(milliseconds: 200),
    this.loadingToIdleDuration = const Duration(milliseconds: 100),
    this.leadingGlowVisible = false,
    this.trailingGlowVisible = true,
  })  : assert(child != null, 'child argument cannot be null'),
        assert(builder != null, 'builder argument cannot be null');

  @override
  _CustomRefreshIndicatorState createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  /// Whether custom refresh indicator can change [IndicatorState] from `idle` to `draging`
  bool _canStart = false;

  double _dragOffset;

  AnimationController _animationController;
  IndicatorController _customRefreshIndicatorData;

  /// Current custom refresh indicator data
  IndicatorController get controller => _customRefreshIndicatorData;

  static const double _kPositionLimit = 1.5;
  static const double _kInitialValue = 0.0;

  @override
  void initState() {
    _dragOffset = 0;
    _canStart = false;

    _customRefreshIndicatorData = IndicatorController(
      value: _kInitialValue,
    );

    _animationController = AnimationController(
      vsync: this,
      upperBound: _kPositionLimit,
      lowerBound: 0.0,
    )
      ..addListener(_updateCustomRefreshIndicatorData)
      ..value = _kInitialValue;

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customRefreshIndicatorData.dispose();
    super.dispose();
  }

  /// Notifies the listeners of the controller
  void _updateCustomRefreshIndicatorData() {
    _customRefreshIndicatorData.updateAndNotify(
      value: _animationController?.value ?? _kInitialValue,
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

    if (_canStart) controller._setIndicatorState(IndicatorState.draging);

    controller._setAxisDirection(notification.metrics.axisDirection);
    return false;
  }

  bool _handleScrollUpdateNotification(ScrollUpdateNotification notification) {
    /// hide when list starts to scroll
    if (controller.state == IndicatorState.draging ||
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
      controller._setIndicatorState(IndicatorState.draging);
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
      duration: widget.dragingToIdleDuration,
      curve: Curves.ease,
    );

    if (!mounted) return;

    controller._setIndicatorState(IndicatorState.idle);
  }

  static final ChildTransformBuilder noChildTransform =
      (context, child, data) => child;

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
