import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'definitions.dart';

typedef RefreshCallback = Future<void> Function();

class CustomRefreshIndicator extends StatefulWidget {
  static const armedFromValue = 1.0;

  final Duration dragingToIdleDuration;
  final Duration armedToLoadingDuration;
  final Duration loadingToIdleDuration;
  final bool leadingGlowVisible;
  final bool trailingGlowVisible;
  final Widget child;
  final CustomIndicatorBuilder indicatorBuilder;
  final RefreshCallback onRefresh;

  CustomRefreshIndicator({
    @required this.child,
    @required this.indicatorBuilder,
    @required this.onRefresh,
    this.dragingToIdleDuration = const Duration(milliseconds: 300),
    this.armedToLoadingDuration = const Duration(milliseconds: 200),
    this.loadingToIdleDuration = const Duration(milliseconds: 100),
    this.leadingGlowVisible = false,
    this.trailingGlowVisible = true,
  })  : assert(child != null),
        assert(indicatorBuilder != null &&
            indicatorBuilder is CustomIndicatorBuilder);

  @override
  _CustomRefreshIndicatorState createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  bool _loading = false;
  bool _canStart = false;
  ScrollDirection _userScrollingDirection = ScrollDirection.forward;
  AxisDirection _axisDirection = AxisDirection.down;
  final _controller = StreamController();
  double _dragOffset;
  CustomRefreshIndicatorState _indicatorState =
      CustomRefreshIndicatorState.idle;

  AnimationController _positionController;

  static const double _kPositionLimit = 1.5;
  static const double _kDragContainerExtentPercentage = 0.15;

  @override
  void initState() {
    _dragOffset = 0;

    _positionController = AnimationController(
      vsync: this,
      upperBound: _kPositionLimit,
      lowerBound: 0,
    )..value = 0;

    super.initState();
  }

  @override
  void dispose() {
    _positionController.dispose();
    _controller.close();
    super.dispose();
  }

  final GlobalKey _key = GlobalKey();

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
        _indicatorState == CustomRefreshIndicatorState.idle;

    _axisDirection = notification.metrics.axisDirection;
    return false;
  }

  bool _handleScrollUpdateNotification(ScrollUpdateNotification notification) {
    /// hide when list starts to scroll
    if (_indicatorState == CustomRefreshIndicatorState.draging ||
        _indicatorState == CustomRefreshIndicatorState.armed) {
      if (notification.metrics.extentBefore > 0.0) {
        debugPrint("CANCELED");
        _hide();
        return false;
      }

      _dragOffset -= notification.scrollDelta;
      _checkDragOffset(notification.metrics.viewportDimension);
      return false;
    }
    return false;
  }

  bool _handleOverscrollNotification(OverscrollNotification notification) {
    _dragOffset -= notification.overscroll / 2.0;
    _checkDragOffset(notification.metrics.viewportDimension);
    return false;
  }

  bool _handleScrollEndNotification(ScrollEndNotification notification) {
    if (_positionController.value >= CustomRefreshIndicator.armedFromValue)
      _start();
    else
      _hide();
    return false;
  }

  bool _handleUserScrollNotification(UserScrollNotification notification) {
    _userScrollingDirection = notification.direction;
    return false;
  }

  void _checkDragOffset(double containerExtent) {
    if (_indicatorState == CustomRefreshIndicatorState.hiding ||
        _indicatorState == CustomRefreshIndicatorState.loading) return;

    double newValue =
        _dragOffset / (containerExtent * _kDragContainerExtentPercentage);

    if (newValue >= CustomRefreshIndicator.armedFromValue) {
      _indicatorState = CustomRefreshIndicatorState.armed;
    } else if (newValue > 0.0) {
      _indicatorState = CustomRefreshIndicatorState.draging;
    }

    // triggers indicator update
    _positionController.value = newValue.clamp(0.0, 1.5);
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

    setState(() {
      _indicatorState = CustomRefreshIndicatorState.loading;
      _loading = true;
    });
    _positionController.animateTo(1.0, duration: widget.armedToLoadingDuration);
    await widget.onRefresh();
    setState(() {
      _loading = false;
      _indicatorState = CustomRefreshIndicatorState.hiding;
    });
    await _positionController.animateTo(0.0,
        duration: widget.loadingToIdleDuration);
    setState(() {
      _indicatorState = CustomRefreshIndicatorState.idle;
    });
  }

  void _hide() async {
    setState(() {
      _indicatorState = CustomRefreshIndicatorState.hiding;
      _dragOffset = 0;
      _canStart = false;
    });
    await _positionController.animateTo(
      0.0,
      duration: widget.dragingToIdleDuration,
      curve: Curves.ease,
    );
    setState(() {
      _indicatorState = CustomRefreshIndicatorState.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = NotificationListener<ScrollNotification>(
      key: _key,
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: widget.child,
      ),
    );

    return Container(
      child: Stack(
        children: <Widget>[
          child,
          AnimatedBuilder(
              animation: _positionController,
              builder: (context, snapshot) {
                return widget.indicatorBuilder(
                  context,
                  CustomRefreshIndicatorData(
                    value: _positionController.value,
                    loading: _loading,
                    direction: _axisDirection,
                    scrollingDirection: _userScrollingDirection,
                    indicatorState: _indicatorState,
                  ),
                );
              }),
        ],
      ),
    );
  }
}
