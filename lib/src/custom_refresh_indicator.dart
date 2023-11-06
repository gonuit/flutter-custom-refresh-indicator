import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

part 'controller.dart';

typedef IndicatorBuilder = Widget Function(
  BuildContext context,
  Widget child,
  IndicatorController controller,
);

typedef OnStateChanged = void Function(IndicatorStateChange change);

extension on IndicatorTrigger {
  IndicatorEdge? getDerivedEdge(
    ScrollNotification notification,
  ) {
    switch (this) {
      case IndicatorTrigger.leadingEdge:
        return IndicatorEdge.leading;
      case IndicatorTrigger.trailingEdge:
        return IndicatorEdge.trailing;
      case IndicatorTrigger.bothEdges:
        final extentBefore = notification.metrics.extentBefore;
        final extentAfter = notification.metrics.extentAfter;
        if (extentAfter != extentBefore) {
          if (extentBefore == 0) {
            return IndicatorEdge.leading;
          } else if (extentAfter == 0) {
            return IndicatorEdge.trailing;
          } else {
            return null;
          }
        } else {
          /// In this case, the side is determined by the direction of the user's
          /// first scrolling gesture, not the trigger itself.
          return null;
        }
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

  /// {@template custom_refresh_indicator.durations}
  /// Defines a durations that are used to control the duration of each phase,
  /// allowing you to adjust the behavior of the refresh indicator.
  /// {@endtemplate}
  final RefreshIndicatorDurations durations;

  /// {@template custom_refresh_indicator.notification_predicate}
  /// Determines whether the received [ScrollNotification] should
  /// be handled by this widget.
  ///
  /// By default, it only accepts *0* depth level notifications. This can be helpful
  /// for more complex layouts with nested scrollviews.
  /// {@endtemplate}
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

  /// {@template custom_refresh_indicator.child}
  /// Part of widget tree that contains scrollable widget (like ListView).
  /// {@endtemplate}
  final Widget child;

  /// Function that builds the custom refresh indicator.
  final IndicatorBuilder builder;

  /// {@template custom_refresh_indicator.on_refresh}
  /// A function that is called when the user drags the refresh indicator
  /// far enough to trigger a "pull to refresh" action.
  /// {@endtemplate}
  final AsyncCallback onRefresh;

  /// {@template custom_refresh_indicator.on_state_changed}
  /// Called on every indicator state change.
  ///
  /// There is no need to use setState in this function, as the indicator will be rebuilt automatically.
  /// {@endtemplate}
  final OnStateChanged? onStateChanged;

  /// {@template custom_refresh_indicator.controller}
  /// The indicator controller stores all the data related
  /// to the refresh indicator widget.
  /// It extends the [Animation] class.
  ///
  /// The indicator controller will be passed to the [builder] method.
  /// {@endtemplate}
  final IndicatorController? controller;

  /// {@macro custom_refresh_indicator.indicator_trigger}
  ///
  /// {@template custom_refresh_indicator.trigger}
  /// By default, the "startEdge" of the scrollable is used.
  /// {@endtemplate}
  final IndicatorTrigger trigger;

  /// {@template custom_refresh_indicator.trigger_mode}
  /// Configures how [CustomRefreshIndicator] can be triggered.
  ///
  /// Works in the same way as the triggerMode of the built-in
  /// [RefreshIndicator] widget.
  ///
  /// Defaults to [IndicatorTriggerMode.onEdge].
  /// {@endtemplate}
  final IndicatorTriggerMode triggerMode;

  /// {@template custom_refresh_indicator.auto_rebuild}
  /// When set to true, the [builder] function will be called whenever the controller changes.
  /// It is set to `true` by default.
  ///
  /// This can be useful for optimizing performance in complex widgets.
  /// When setting this to false, you can manage which part of the ui you want to rebuild,
  /// such as using the [AnimationBuilder] widget in conjunction with [IndicatorController] or
  /// transition widgets, for instance [FadeTransition].
  /// {@endtemplate}
  final bool autoRebuild;

  /// A [ScrollNotificationPredicate] that checks whether
  /// `notification.depth == 0`, which means that the notification did not bubble
  /// through any intervening scrolling widgets.
  static bool defaultScrollNotificationPredicate(ScrollNotification notification) {
    return notification.depth == 0;
  }

  CustomRefreshIndicator({
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
    @Deprecated('In favor of durations parameter')
    Duration? indicatorCancelDuration = const Duration(milliseconds: 300),
    @Deprecated('In favor of durations parameter')
    Duration? indicatorSettleDuration = const Duration(milliseconds: 150),
    @Deprecated('In favor of durations parameter')
    Duration? indicatorFinalizeDuration = const Duration(milliseconds: 100),
    @Deprecated('In favor of durations parameter') Duration? completeStateDuration,
    this.leadingScrollIndicatorVisible = false,
    this.trailingScrollIndicatorVisible = true,
    RefreshIndicatorDurations durations = const RefreshIndicatorDurations(),
  })  : assert(
          containerExtentPercentageToArmed == null || offsetToArmed == null,
          'Providing `extentPercentageToArmed` argument take no effect when `offsetToArmed` is provided. '
          'Remove redundant argument.',
        ),
        durations = RefreshIndicatorDurations(
          cancelDuration: indicatorCancelDuration ?? durations.cancelDuration,
          completeDuration: completeStateDuration ?? durations.completeDuration,
          finalizeDuration: indicatorFinalizeDuration ?? durations.finalizeDuration,
          settleDuration: indicatorSettleDuration ?? durations.settleDuration,
        ),
        // set the default extent percentage value if not provided
        containerExtentPercentageToArmed = containerExtentPercentageToArmed ?? defaultContainerExtentPercentageToArmed,
        super(key: key);

  @override
  CustomRefreshIndicatorState createState() => CustomRefreshIndicatorState();
}

class CustomRefreshIndicatorState extends State<CustomRefreshIndicator> with TickerProviderStateMixin {
  /// Whether custom refresh indicator can change
  /// [IndicatorState] from `idle` to `dragging`
  ///
  /// This state is determined by gestures and does not take into account
  /// the *isRefreshEnabled* flag.
  // bool _canStart = false;

  /// Indicating that indicator is currently stopping drag.
  /// When true, user is not able to perform any action.
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
    _customRefreshIndicatorController = widget.controller ?? IndicatorController._();

    _animationController = AnimationController(
      vsync: this,
      upperBound: _kPositionLimit,
      lowerBound: _kInitialValue,
      value: _kInitialValue,
    )..addListener(_updateCustomRefreshIndicatorValue);

    super.initState();
  }

  /// Triggers a rebuild of the indicator widget
  void _update() => setState(() {});

  @visibleForTesting
  @protected
  void setIndicatorState(IndicatorState newState) {
    final onStateChanged = widget.onStateChanged;
    if (onStateChanged != null && controller.state != newState) {
      onStateChanged(IndicatorStateChange(controller.state, newState));
    }
    controller.setIndicatorState(newState);
    // Triggers a rebuild of the widget to ensure that the new state
    // will be handled correctly by the indicator widget.
    _update();
  }

  /// Notifies the listeners of the controller
  void _updateCustomRefreshIndicatorValue() => _customRefreshIndicatorController.setValue(_animationController.value);

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
        return notification.metrics.extentBefore == 0 || notification.metrics.extentAfter == 0;
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
        ..setIndicatorEdge(widget.trigger.getDerivedEdge(notification));
      setIndicatorState(IndicatorState.dragging);
    }

    return canStart;
  }

  bool _handleScrollUpdateNotification(ScrollUpdateNotification notification) {
    // Calculate the edge if not defined and possible.
    // This may apply to two-way lists on the iOS platform with bouncing physics.
    if (!controller.hasEdge && notification.scrollDelta != null) {
      if (notification.metrics.extentBefore == 0 && notification.scrollDelta!.isNegative) {
        controller
          ..setIndicatorDragDetails(notification.dragDetails)
          ..setIndicatorEdge(IndicatorEdge.leading);
        setIndicatorState(IndicatorState.dragging);
      } else if (notification.metrics.extentAfter == 0 && !notification.scrollDelta!.isNegative) {
        controller
          ..setIndicatorDragDetails(notification.dragDetails)
          ..setIndicatorEdge(IndicatorEdge.trailing);
        setIndicatorState(IndicatorState.dragging);
      }
    }

    /// When the controller is armed, but the scroll update event is not triggered
    /// by the user, the refresh action should be triggered
    if (controller.state.isArmed && notification.dragDetails == null) {
      controller.setIndicatorDragDetails(null);
      _start();

      /// Handle the indicator state depending on scrolling direction
    } else if (controller.state.isDragging || controller.state.isArmed) {
      controller.setIndicatorDragDetails(notification.dragDetails);

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
        notification.overscroll.isNegative ? IndicatorEdge.leading : IndicatorEdge.trailing,
      );
      // Inform indicator widget of edge change
      _update();
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
    if (controller.state.isCanceling || controller.state.isFinalizing || controller.state.isLoading) return;

    double newValue;

    final offsetToArmed = widget.offsetToArmed;

    /// If [offsetToArmed] is provided then it will be used otherwise
    /// [extentPercentageToArmed]
    if (offsetToArmed != null) {
      newValue = _dragOffset / offsetToArmed;
    } else {
      final extentPercentageToArmed = widget.containerExtentPercentageToArmed;

      newValue = _dragOffset / (containerExtent * extentPercentageToArmed);
    }

    if (newValue > 0.0 && newValue < CustomRefreshIndicator.armedFromValue && !controller.state.isDragging) {
      setIndicatorState(IndicatorState.dragging);
    } else if (newValue >= CustomRefreshIndicator.armedFromValue && !controller.state.isArmed) {
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
        duration: widget.durations.settleDuration,
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
    final completeStateDuration = widget.durations.completeDuration;
    if (completeStateDuration != null) {
      setIndicatorState(IndicatorState.complete);
      await Future.delayed(completeStateDuration);
    }

    if (!mounted) return;
    setIndicatorState(IndicatorState.finalizing);
    await _animationController.animateTo(0.0, duration: widget.durations.finalizeDuration);

    if (!mounted) return;
    controller.setIndicatorEdge(null);
    setIndicatorState(IndicatorState.idle);
  }

  Future<void> _hide() async {
    setIndicatorState(IndicatorState.canceling);
    _dragOffset = 0;
    await _animationController.animateTo(
      0.0,
      duration: widget.durations.cancelDuration,
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
        // ignore: deprecated_member_use_from_same_package
        (builder is IndicatorBuilderDelegate && (builder as IndicatorBuilderDelegate).autoRebuild)) {
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
