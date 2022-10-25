import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'controller.dart';

typedef IndicatorBuilder = Widget Function(
  BuildContext context,
  Widget child,
  IndicatorController controller,
);

typedef OnStateChanged = void Function(IndicatorStateChange change);

extension on IndicatorTrigger {
  IndicatorEdge? get derivedEdge {
    switch (this) {
      case IndicatorTrigger.leadingEdge:
        return IndicatorEdge.leading;
      case IndicatorTrigger.trailingEdge:
        return IndicatorEdge.trailing;

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

  /// Duration of hiding the indicator when dragging was stopped before
  /// the indicator was armed (the *onRefresh* callback was not called).
  ///
  /// The default is 300 milliseconds.
  final Duration indicatorCancelDuration;

  /// The time of settling the pointer on the target location after releasing
  /// the pointer in the armed state.
  ///
  /// During this process, the value of the indicator decreases from its current value,
  /// which can be greater than or equal to 1.0 but less or equal to 1.5,
  /// to a target value of `1.0`.
  /// During this process, the state is set to [IndicatorState.loading].
  ///
  /// The default is 150 milliseconds.
  final Duration indicatorSettleDuration;

  /// Duration of hiding the pointer after the [onRefresh] function completes.
  ///
  /// During this time, the value of the controller decreases from `1.0` to `0.0`
  /// with a state set to [IndicatorState.finalizing].
  ///
  /// The default is 100 milliseconds.
  final Duration indicatorFinalizeDuration;

  /// Duration for which the indicator remains at value of *1.0* and
  /// [IndicatorState.complete] state after the [onRefresh] function completes.
  final Duration? completeStateDuration;

  /// Determines whether the received [ScrollNotification] should
  /// be handled by this widget.
  ///
  /// By default, it only accepts *0* depth level notifications. This can be helpful
  /// for more complex layouts with nested scrollviews.
  final ScrollNotificationPredicate notificationPredicate;

  /// Whether to display leading scroll indicator
  final bool leadingScrollIndicatorVisible;

  /// Whether to display trailing scroll indicator
  final bool trailingScrollIndicatorVisible;

  /// The distance in number of pixels that the user should drag to arm the indicator.
  /// The armed indicator will trigger the [onRefresh] function when the gesture is completed.
  ///
  /// If not specified, [containerExtentPercentageToArmed] will be used instead.
  final double? offsetToArmed;

  /// The distance the user must scroll for the indicator to be armed,
  /// as a percentage of the scrollable's container extent.
  ///
  /// If the [offsetToArmed] argument is specified, it will be used instead,
  /// and this value will not take effect.
  ///
  /// The default value equals `0.1(6)`.
  final double containerExtentPercentageToArmed;

  /// Part of widget tree that contains scrollable widget (like ListView).
  final Widget child;

  /// Function that builds the custom refresh indicator.
  final IndicatorBuilder builder;

  /// A function that is called when the user drags the refresh indicator
  /// far enough to trigger a "pull to refresh" action.
  final AsyncCallback onRefresh;

  /// Called on every indicator state change.
  final OnStateChanged? onStateChanged;

  /// The indicator controller stores all the data related
  /// to the refresh indicator widget.
  /// It extends the [ChangeNotifier] class.
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

  /// Configures how [CustomRefreshIndicator] can be triggered.
  ///
  /// Works in the same way as the triggerMode of the built-in
  /// [RefreshIndicator] widget.
  ///
  /// Defaults to [IndicatorTriggerMode.onEdge].
  final IndicatorTriggerMode triggerMode;

  /// When set to true, the [builder] function will be called whenever the controller changes.
  /// It is set to `true` by default.
  ///
  /// This can be useful for optimizing performance in complex widgets.
  /// When setting this to false, you can manage which part of the ui you want to rebuild,
  /// such as using the [AnimationBuilder] widget in conjunction with [IndicatorController].
  final bool autoRebuild;

  const CustomRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    required this.builder,
    this.controller,
    this.trigger = IndicatorTrigger.leadingEdge,
    this.triggerMode = IndicatorTriggerMode.onEdge,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.autoRebuild = true,
    this.offsetToArmed,
    this.onStateChanged,
    double? containerExtentPercentageToArmed,
    this.indicatorCancelDuration = const Duration(milliseconds: 300),
    this.indicatorSettleDuration = const Duration(milliseconds: 150),
    this.indicatorFinalizeDuration = const Duration(milliseconds: 100),
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
      case IndicatorTrigger.leadingEdge:
        return notification.metrics.extentBefore == 0;
      case IndicatorTrigger.trailingEdge:
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
        controller.state.isIdle &&
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
    // Calculate the edge if not defined and possible.
    // This may apply to two-way lists on the iOS platform with bouncing physics.
    if (!controller.hasEdge && notification.scrollDelta != null) {
      if (notification.metrics.extentBefore == 0 &&
          notification.scrollDelta!.isNegative) {
        controller
          ..setIndicatorEdge(IndicatorEdge.leading)
          ..setIndicatorState(IndicatorState.dragging);
      } else if (notification.metrics.extentAfter == 0 &&
          !notification.scrollDelta!.isNegative) {
        controller
          ..setIndicatorEdge(IndicatorEdge.trailing)
          ..setIndicatorState(IndicatorState.dragging);
      }
    }

    /// When the controller is armed, but the scroll update event is not triggered
    /// by the user, the refresh action should be triggered
    if (controller.state.isArmed && notification.dragDetails == null) {
      _start();

      /// Handle the indicator state depending on scrolling direction
    } else if (controller.state.isDragging || controller.state.isArmed) {
      switch (controller.edge) {
        case IndicatorEdge.leading:
          if (notification.metrics.extentBefore > 0.0) {
            _hide();
          } else {
            _dragOffset -= notification.scrollDelta!;

            _calculateDragOffset(notification.metrics.viewportDimension);
          }
          break;

        case IndicatorEdge.trailing:
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
    }

    return false;
  }

  bool _handleOverscrollNotification(OverscrollNotification notification) {
    if (!controller.hasEdge) {
      controller.setIndicatorEdge(
        notification.overscroll.isNegative
            ? IndicatorEdge.leading
            : IndicatorEdge.trailing,
      );
    }

    if (controller.edge!.isLeading) {
      _dragOffset -= notification.overscroll;
    } else {
      _dragOffset += notification.overscroll;
    }
    _calculateDragOffset(notification.metrics.viewportDimension);
    return false;
  }

  bool _handleScrollEndNotification(ScrollEndNotification notification) {
    if (controller.state.isArmed) {
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
    if (!controller.state.isIdle) {
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
    setIndicatorState(IndicatorState.settling);
    setIndicatorState(IndicatorState.loading);
  }

  Future<void> refresh({
    Duration draggingDuration = const Duration(milliseconds: 300),
    Curve draggingCurve = Curves.linear,
  }) async {
    if (!controller.state.isIdle) {
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
      if (controller.state.isLoading) {
        await hide();
      }
    }
  }

  /// Hides indicator
  Future<void> hide() {
    if (!controller.state.isLoading) {
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
    if (controller.state.isCanceling ||
        controller.state.isFinalizing ||
        controller.state.isLoading) return;

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
        !controller.state.isDragging) {
      setIndicatorState(IndicatorState.dragging);
    } else if (newValue >= CustomRefreshIndicator.armedFromValue &&
        !controller.state.isArmed) {
      setIndicatorState(IndicatorState.armed);
    }

    /// triggers indicator update
    _animationController.value = newValue.clamp(0.0, _kPositionLimit);
  }

  /// Notifications can only be handled in the "dragging" and "armed" state.
  bool canHandleNotifications(IndicatorController controller) =>
      controller.state.isDragging || controller.state.isArmed;

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

    if (controller.state.isIdle) {
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

      setIndicatorState(IndicatorState.settling);

      await _animationController.animateTo(
        1.0,
        duration: widget.indicatorSettleDuration,
      );
      setIndicatorState(IndicatorState.loading);
      await widget.onRefresh();
    } finally {
      await _hideAfterRefresh();
    }
  }

  /// Hides an indicator after the `onRefresh` function.
  Future<void> _hideAfterRefresh() async {
    assert(controller.state.isLoading);

    if (!mounted) return;

    /// optional complete state
    final completeStateDuration = widget.completeStateDuration;
    if (completeStateDuration != null) {
      setIndicatorState(IndicatorState.complete);
      await Future.delayed(completeStateDuration);
    }

    if (!mounted) return;
    setIndicatorState(IndicatorState.finalizing);
    await _animationController.animateTo(0.0,
        duration: widget.indicatorFinalizeDuration);

    if (!mounted) return;
    controller.setIndicatorEdge(null);
    setIndicatorState(IndicatorState.idle);
  }

  Future<void> _hide() async {
    setIndicatorState(IndicatorState.canceling);
    _dragOffset = 0;
    await _animationController.animateTo(
      0.0,
      duration: widget.indicatorCancelDuration,
      curve: Curves.ease,
    );

    if (!mounted) return;
    controller.setIndicatorEdge(null);
    setIndicatorState(IndicatorState.idle);
  }

  @override
  Widget build(BuildContext context) {
    final child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleScrollIndicatorNotification,
        child: widget.child,
      ),
    );

    final builder = widget.builder;

    if (widget.autoRebuild ||
        (builder is IndicatorBuilderDelegate &&
            (builder as IndicatorBuilderDelegate).autoRebuild)) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) => builder(context, child, controller),
      );
    } else {
      return builder(context, child, controller);
    }
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
