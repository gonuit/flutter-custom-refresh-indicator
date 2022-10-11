import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'controller.dart';

typedef IndicatorBuilder = Widget Function(
  BuildContext context,
  Widget child,
  IndicatorController controller,
);

typedef OnRefresh = Future<void> Function();
typedef OnStateChanged = void Function(IndicatorStateChange change);

extension on IndicatorTrigger {
  IndicatorEdge? get derivedEdge {
    switch (this) {
      case IndicatorTrigger.startEdge:
        return IndicatorEdge.start;
      case IndicatorTrigger.endEdge:
        return IndicatorEdge.end;

      /// In this case, the side is determined by the direction of the user's
      /// first scrolling gesture, not the trigger itself.
      case IndicatorTrigger.bothEdges:
        return null;
    }
  }
}

class CustomRefreshIndicator extends StatefulWidget {
  /// The value from which [IndicatorController] is considered to be armed.
  static const armedFromValue = 1.0;

  /// The default distance the user must over-scroll for the indicator
  /// to be armed, as a percentage of the scrollable's container extent.
  ///
  /// This value matches the extent to armed of built-in [RefreshIndicator] widget.
  static const defaultContainerExtentPercentageToArmed = 0.25 * (1 / 1.5);

  /// Duration of changing [IndicatorController] value from `<1.0` to `0.0`.
  /// When user stop dragging list before it become to armed [IndicatorState].
  final Duration draggingToIdleDuration;

  /// Duration of changing [IndicatorController] value from `<=1.5` to `1.0`.
  /// Will start just before [onRefresh] function invocation.
  final Duration armedToLoadingDuration;

  /// Duration of changing [IndicatorController] value from `1.0` to `0.0`
  /// when [onRefresh] callback was completed.
  ///
  /// Occurs after `loading` or `complete` state.
  final Duration loadingToIdleDuration;

  /// {@macro custom_refresh_indicator.complete_state}
  final Duration? completeStateDuration;

  /// A check that specifies whether a [ScrollNotification] should be
  /// handled by this widget.
  ///
  /// By default, checks whether `notification.depth == 0`. Set it to something
  /// else for more complicated layouts.
  final ScrollNotificationPredicate notificationPredicate;

  /// Whether to display leading scroll indicator
  final bool leadingScrollIndicatorVisible;

  /// Whether to display trailing scroll indicator
  final bool trailingScrollIndicatorVisible;

  /// Number of pixels that user should drag to change [IndicatorState] from idle to armed.
  final double? offsetToArmed;

  /// The distance the user must scroll for the indicator to be armed,
  /// as a percentage of the scrollable's container extent.
  ///
  /// If the [offsetToArmed] argument is specified, it will be used instead,
  /// and this value will not take effect.
  ///
  /// The default value equals `0.1(6)`.
  final double containerExtentPercentageToArmed;

  /// Part of widget tree that contains scrollable element (like ListView).
  /// Scroll notifications from the first scrollable element will be used
  /// to calculate [IndicatorController] data.
  final Widget child;

  /// Allows you to trigger the indicator from the other side
  /// of the scrollview (from the end of the list).
  // final bool? reversed;

  /// Function in wich custom refresh indicator should be implemented.
  ///
  /// ### IMPORTANT:
  /// IT IS NOT CALLED ON EVERY [IndicatorController] DATA CHANGE.
  /// To rebuild widget on every change, consider
  /// using [IndicatorController] that is passed to this function as the third argument
  /// in combination with [AnimationBuilder].
  final IndicatorBuilder builder;

  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh.
  /// The returned [Future] must complete when the refresh operation is finished.
  final OnRefresh onRefresh;

  /// Called on every indicator state change.
  final OnStateChanged? onStateChanged;

  /// Indicator controller keeps all thata related to refresh indicator.
  /// It extends [ChangeNotifier] so that it could be listen for changes.
  ///
  /// TIP:
  /// Consider using it in combination with [AnimationBuilder] as animation argument
  ///
  /// The indicator controller will be passed as the third argument to the [builder] method.
  ///
  /// To better understand this data, look at example app.
  final IndicatorController? controller;

  /// {@macro custom_refresh_indicator.indicator_trigger}
  ///
  /// By default, the "startEdge" of the scrollable is used.
  final IndicatorTrigger trigger;

  /// Used to configure how [CustomRefreshIndicator] can be triggered.
  ///
  /// Works in the same way as the triggerMode of the built-in
  /// [RefreshIndicator] widget.
  ///
  /// Defaults to [IndicatorTriggerMode.onEdge].
  final IndicatorTriggerMode triggerMode;

  const CustomRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    required this.builder,
    this.trigger = IndicatorTrigger.startEdge,
    this.triggerMode = IndicatorTriggerMode.onEdge,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.controller,
    this.offsetToArmed,
    this.onStateChanged,
    double? containerExtentPercentageToArmed,
    this.draggingToIdleDuration = const Duration(milliseconds: 300),
    this.armedToLoadingDuration = const Duration(milliseconds: 200),
    this.loadingToIdleDuration = const Duration(milliseconds: 100),
    this.completeStateDuration,
    this.leadingScrollIndicatorVisible = false,
    this.trailingScrollIndicatorVisible = true,
  })  : assert(
          containerExtentPercentageToArmed == null || offsetToArmed == null,
          'Providing `extentPercentageToArmed` argument take no effect when `offsetToArmed` is provided. '
          'Remove redundant argument.',
        ),
        // set the default extent percentage value if not provided
        containerExtentPercentageToArmed = containerExtentPercentageToArmed ??
            defaultContainerExtentPercentageToArmed,
        super(key: key);

  @override
  CustomRefreshIndicatorState createState() => CustomRefreshIndicatorState();
}

class CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  /// Whether custom refresh indicator can change
  /// [IndicatorState] from `idle` to `dragging`
  ///
  /// This state is determined by gestures and does not take into account
  /// the *isRefreshEnabled* flag.
  // bool _canStart = false;

  /// Indicating that indicator is currently stopping drag.
  /// When true, user is not able to performe any action.
  bool _isStopingDrag = false;

  late double _dragOffset;

  late AnimationController _animationController;
  late bool _controllerProvided;
  late IndicatorController _customRefreshIndicatorController;

  /// Current [IndicatorController]
  IndicatorController get controller => _customRefreshIndicatorController;

  static const double _kPositionLimit = 1.5;
  static const double _kInitialValue = 0.0;

  @override
  void initState() {
    _dragOffset = 0;

    _controllerProvided = widget.controller != null;
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

  @visibleForTesting
  @protected
  void setIndicatorState(IndicatorState newState) {
    final onStateChanged = widget.onStateChanged;
    if (onStateChanged != null && controller.state != newState) {
      onStateChanged(IndicatorStateChange(controller.state, newState));
    }
    controller.setIndicatorState(newState);
  }

  /// Notifies the listeners of the controller
  void _updateCustomRefreshIndicatorValue() =>
      _customRefreshIndicatorController.setValue(_animationController.value);

  bool _handleScrollIndicatorNotification(
    OverscrollIndicatorNotification notification,
  ) {
    if (notification.depth != 0) return false;
    if (notification.leading) {
      if (!widget.leadingScrollIndicatorVisible) {
        notification.disallowIndicator();
      }
    } else {
      if (!widget.trailingScrollIndicatorVisible) {
        notification.disallowIndicator();
      }
    }
    return true;
  }

  bool _canStartFromCurrentTrigger(
    ScrollNotification notification,
    IndicatorTrigger trigger,
  ) {
    switch (trigger) {
      case IndicatorTrigger.startEdge:
        return notification.metrics.extentBefore == 0;
      case IndicatorTrigger.endEdge:
        return notification.metrics.extentAfter == 0;
      case IndicatorTrigger.bothEdges:
        return notification.metrics.extentBefore == 0 ||
            notification.metrics.extentAfter == 0;
    }
  }

  /// Check whether the pull to refresh gesture can be activated.
  bool _checkCanStart(ScrollNotification notification) {
    final isValidMode = (notification is ScrollStartNotification &&
            // whether the drag was triggered by the user
            notification.dragDetails != null) ||
        (notification is ScrollUpdateNotification &&
            // whether the drag was triggered by the user
            notification.dragDetails != null &&
            widget.triggerMode == IndicatorTriggerMode.anywhere);

    final canStart = isValidMode &&
        controller.isRefreshEnabled &&
        controller.isIdle &&
        _canStartFromCurrentTrigger(notification, widget.trigger);

    if (canStart) {
      controller
        ..setAxisDirection(notification.metrics.axisDirection)
        ..setIndicatorEdge(widget.trigger.derivedEdge);
      setIndicatorState(IndicatorState.dragging);
    }

    return canStart;
  }

  bool _handleScrollUpdateNotification(ScrollUpdateNotification notification) {
    /// hide when list starts to scroll
    if (controller.isDragging || controller.isArmed) {
      switch (controller.edge) {
        case IndicatorEdge.start:
          if (notification.metrics.extentBefore > 0.0) {
            _hide();
          } else {
            _dragOffset -= notification.scrollDelta!;
            _calculateDragOffset(notification.metrics.viewportDimension);
          }
          break;

        case IndicatorEdge.end:
          if (notification.metrics.extentAfter > 0.0) {
            _hide();
          } else {
            _dragOffset += notification.scrollDelta!;
            _calculateDragOffset(notification.metrics.viewportDimension);
          }
          break;

        /// Indicator was unable to determine the side by which it was
        /// triggered, therefore indicator needs to be hidden.
        case null:
          _hide();
          break;
      }

      if (controller.isArmed && notification.dragDetails == null) {
        _start();
      }
    }

    return false;
  }

  bool _handleOverscrollNotification(OverscrollNotification notification) {
    if (!controller.hasEdge) {
      controller.setIndicatorEdge(
        notification.overscroll.isNegative
            ? IndicatorEdge.start
            : IndicatorEdge.end,
      );
    }

    if (controller.edge!.isStart) {
      _dragOffset -= notification.overscroll;
    } else {
      _dragOffset += notification.overscroll;
    }
    _calculateDragOffset(notification.metrics.viewportDimension);
    return false;
  }

  bool _handleScrollEndNotification(ScrollEndNotification notification) {
    if (controller.isArmed) {
      _start();
    } else {
      _hide();
    }
    return false;
  }

  /// Show the pointer programmatically. The pointer will not hide
  /// automatically, call the [hide] method to hide the pointer.
  ///
  /// This method is only responsible for the visual part, if you want
  /// to do the whole process with a [onRefresh] call, use the [refresh]
  /// method instead.
  Future<void> show({
    Duration draggingDuration = const Duration(milliseconds: 300),
    Curve draggingCurve = Curves.linear,
  }) async {
    if (!controller.isIdle) {
      throw StateError(
        "Cannot show indicator. "
        "Controller must be in the idle state. "
        "Current state: ${controller.state.name}.",
      );
    }
    setIndicatorState(IndicatorState.dragging);
    await _animationController.animateTo(
      1.0,
      duration: draggingDuration,
      curve: draggingCurve,
    );
    setIndicatorState(IndicatorState.armed);
    setIndicatorState(IndicatorState.loading);
  }

  Future<void> refresh({
    Duration draggingDuration = const Duration(milliseconds: 300),
    Curve draggingCurve = Curves.linear,
  }) async {
    if (!controller.isIdle) {
      throw StateError(
        "Cannot refresh. "
        "Controller must be in the idle state. "
        "Current state: ${controller.state.name}.",
      );
    }

    await show(
      draggingDuration: draggingDuration,
      draggingCurve: draggingCurve,
    );
    try {
      await widget.onRefresh();
    } finally {
      /// If the user has programmatically hidden the pointer
      /// so it is not in "loading" state, then nothing needs to be done.
      if (controller.isLoading) {
        await hide();
      }
    }
  }

  /// Hides indicator
  Future<void> hide() {
    if (!controller.isLoading) {
      throw StateError(
        'Controller must be in the loading state. '
        'Current state: ${controller.state}',
      );
    }
    return _hideAfterRefresh();
  }

  bool _handleUserScrollNotification(UserScrollNotification notification) {
    controller.setScrollingDirection(notification.direction);
    return false;
  }

  void _calculateDragOffset(double containerExtent) {
    if (controller.isHiding || controller.isLoading) return;

    double newValue;

    final offsetToArmed = widget.offsetToArmed;

    /// If [offestToArmed] is provided then it will be used otherwise
    /// [extentPercentageToArmed]
    if (offsetToArmed != null) {
      newValue = _dragOffset / offsetToArmed;
    } else {
      final extentPercentageToArmed = widget.containerExtentPercentageToArmed;

      newValue = _dragOffset / (containerExtent * extentPercentageToArmed);
    }

    if (newValue > 0.0 &&
        newValue < CustomRefreshIndicator.armedFromValue &&
        !controller.isDragging) {
      setIndicatorState(IndicatorState.dragging);
    } else if (newValue >= CustomRefreshIndicator.armedFromValue &&
        !controller.isArmed) {
      setIndicatorState(IndicatorState.armed);
    }

    /// triggers indicator update
    _animationController.value = newValue.clamp(0.0, _kPositionLimit);
  }

  /// Notifications can only be handled in the "dragging" and "armed" state.
  bool canHandleNotifications(IndicatorController controller) =>
      controller.isDragging || controller.isArmed;

  bool _handleScrollNotification(ScrollNotification notification) {
    /// if notification predicate is not matched then notification
    /// will not be handled by this widget
    if (!widget.notificationPredicate(notification)) return false;

    if (_isStopingDrag) {
      controller._shouldStopDrag = false;
      return false;
    } else if (controller._shouldStopDrag) {
      controller._shouldStopDrag = false;
      _isStopingDrag = true;

      _hide().whenComplete(() {
        _isStopingDrag = false;
      });
      return false;
    }

    if (controller.isIdle) {
      _checkCanStart(notification);
      return false;
    }

    if (!canHandleNotifications(controller)) {
      return false;
    } else if (notification is ScrollUpdateNotification) {
      return _handleScrollUpdateNotification(notification);
    } else if (notification is OverscrollNotification) {
      return _handleOverscrollNotification(notification);
    } else if (notification is ScrollEndNotification) {
      return _handleScrollEndNotification(notification);
    } else if (notification is UserScrollNotification) {
      return _handleUserScrollNotification(notification);
    }

    return false;
  }

  void _start() async {
    try {
      _dragOffset = 0;

      setIndicatorState(IndicatorState.loading);
      await _animationController.animateTo(1.0,
          duration: widget.armedToLoadingDuration);
      await widget.onRefresh();
    } finally {
      await _hideAfterRefresh();
    }
  }

  /// Hides an indicator after the `onRefresh` function.
  Future<void> _hideAfterRefresh() async {
    assert(controller.isLoading);

    if (!mounted) return;

    /// optional complete state
    final completeStateDuration = widget.completeStateDuration;
    if (completeStateDuration != null) {
      setIndicatorState(IndicatorState.complete);
      await Future.delayed(completeStateDuration);
    }

    if (!mounted) return;
    setIndicatorState(IndicatorState.hiding);
    await _animationController.animateTo(0.0,
        duration: widget.loadingToIdleDuration);

    if (!mounted) return;
    controller.setIndicatorEdge(null);
    setIndicatorState(IndicatorState.idle);
  }

  Future<void> _hide() async {
    setIndicatorState(IndicatorState.hiding);
    _dragOffset = 0;
    await _animationController.animateTo(
      0.0,
      duration: widget.draggingToIdleDuration,
      curve: Curves.ease,
    );

    if (!mounted) return;
    controller.setIndicatorEdge(null);
    setIndicatorState(IndicatorState.idle);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: _handleScrollIndicatorNotification,
          child: widget.child,
        ),
      ),
      controller,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();

    /// Provided controller should be disposed by the user.
    if (!_controllerProvided) {
      _customRefreshIndicatorController.dispose();
    }
    super.dispose();
  }
}
