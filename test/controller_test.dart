import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/custom_refresh_indicator.dart';

class TestListener {
  int _called = 0;
  int get called => _called;

  onNotify() {
    _called++;
  }

  void reset() {
    _called = 0;
  }
}

void main() {
  late IndicatorController controller;
  final listener = TestListener();

  setUp(() {
    controller = IndicatorController();
    controller.addListener(listener.onNotify);
  });

  tearDown(() {
    listener.reset();
  });

  test("controller state is created correctly", () {
    expect(controller.state, equals(IndicatorState.idle));
    expect(controller.value, equals(0.0));
    expect(controller.direction, AxisDirection.down);
    expect(controller.isIdle, isTrue);
    expect(controller.isDragging, isFalse);
    expect(controller.isHiding, isFalse);
    expect(controller.isArmed, isFalse);
    expect(controller.isLoading, isFalse);
    expect(controller.isComplete, isFalse);
    expect(controller.isRefreshEnabled, isTrue);
    expect(controller.isScrollIdle, isTrue);
    expect(controller.isScrollingForward, isFalse);
    expect(controller.isScrollingReverse, isFalse);
    expect(controller.isHorizontalDirection, isFalse);

    expect(listener.called, equals(0));
  });

  test("setValue method changes value and notifies listeners", () {
    expect(listener.called, equals(0));
    expect(controller.value, equals(0.0));
    controller.setValue(0.2);
    expect(listener.called, equals(1));
    expect(controller.value, equals(0.2));
    controller.setValue(1.5);
    expect(listener.called, equals(2));
    expect(controller.value, equals(1.5));
  });

  test("state getters works correctly", () {
    expect(controller.state, equals(IndicatorState.idle));
    expect(controller.isIdle, isTrue);
    expect(controller.isDragging, isFalse);
    expect(controller.isHiding, isFalse);
    expect(controller.isArmed, isFalse);
    expect(controller.isLoading, isFalse);
    expect(controller.isComplete, isFalse);

    controller.setIndicatorState(IndicatorState.dragging);
    expect(controller.isIdle, isFalse);
    expect(controller.isDragging, isTrue);
    expect(controller.isHiding, isFalse);
    expect(controller.isArmed, isFalse);
    expect(controller.isLoading, isFalse);
    expect(controller.isComplete, isFalse);

    controller.setIndicatorState(IndicatorState.hiding);
    expect(controller.isIdle, isFalse);
    expect(controller.isDragging, isFalse);
    expect(controller.isHiding, isTrue);
    expect(controller.isArmed, isFalse);
    expect(controller.isLoading, isFalse);
    expect(controller.isComplete, isFalse);

    controller.setIndicatorState(IndicatorState.armed);
    expect(controller.isIdle, isFalse);
    expect(controller.isDragging, isFalse);
    expect(controller.isHiding, isFalse);
    expect(controller.isArmed, isTrue);
    expect(controller.isLoading, isFalse);
    expect(controller.isComplete, isFalse);

    controller.setIndicatorState(IndicatorState.loading);
    expect(controller.isIdle, isFalse);
    expect(controller.isDragging, isFalse);
    expect(controller.isHiding, isFalse);
    expect(controller.isArmed, isFalse);
    expect(controller.isLoading, isTrue);
    expect(controller.isComplete, isFalse);

    controller.setIndicatorState(IndicatorState.complete);
    expect(controller.isIdle, isFalse);
    expect(controller.isDragging, isFalse);
    expect(controller.isHiding, isFalse);
    expect(controller.isArmed, isFalse);
    expect(controller.isLoading, isFalse);
    expect(controller.isComplete, isTrue);
  });

  test("refresh changes correctly and notifies listeners", () {
    expect(listener.called, equals(0));
    expect(controller.isRefreshEnabled, isTrue);
    controller.disableRefresh();
    expect(listener.called, equals(1));
    expect(controller.isRefreshEnabled, isFalse);
    controller.enableRefresh();
    expect(listener.called, equals(2));
    expect(controller.isRefreshEnabled, isTrue);
  });

  test("setAxisDirection works correctly", () {
    expect(listener.called, equals(0));
    controller.setAxisDirection(AxisDirection.down);
    expect(listener.called, equals(1));
    expect(controller.direction, AxisDirection.down);
    controller.setAxisDirection(AxisDirection.up);
    expect(listener.called, equals(2));
    expect(controller.direction, AxisDirection.up);
    controller.setAxisDirection(AxisDirection.left);
    expect(listener.called, equals(3));
    expect(controller.direction, AxisDirection.left);
    controller.setAxisDirection(AxisDirection.right);
    expect(listener.called, equals(4));
    expect(controller.direction, AxisDirection.right);
  });

  test("isHorizontalDirection getter works correctly", () {
    controller.setAxisDirection(AxisDirection.down);
    expect(controller.isHorizontalDirection, isFalse);
    controller.setAxisDirection(AxisDirection.up);
    expect(controller.isHorizontalDirection, isFalse);
    controller.setAxisDirection(AxisDirection.left);
    expect(controller.isHorizontalDirection, isTrue);
    controller.setAxisDirection(AxisDirection.right);
    expect(controller.isHorizontalDirection, isTrue);
  });

  test("isVerticalDirection getter works correctly", () {
    controller.setAxisDirection(AxisDirection.down);
    expect(controller.isVerticalDirection, isTrue);
    controller.setAxisDirection(AxisDirection.up);
    expect(controller.isVerticalDirection, isTrue);
    controller.setAxisDirection(AxisDirection.left);
    expect(controller.isVerticalDirection, isFalse);
    controller.setAxisDirection(AxisDirection.right);
    expect(controller.isVerticalDirection, isFalse);
  });

  test("setScrollDirection method works correctly", () {
    expect(listener.called, equals(0));
    controller.setScrollingDirection(ScrollDirection.forward);
    expect(listener.called, equals(1));
    expect(controller.scrollingDirection, ScrollDirection.forward);
    controller.setScrollingDirection(ScrollDirection.idle);
    expect(listener.called, equals(2));
    expect(controller.scrollingDirection, ScrollDirection.idle);
    controller.setScrollingDirection(ScrollDirection.reverse);
    expect(listener.called, equals(3));
    expect(controller.scrollingDirection, ScrollDirection.reverse);
  });

  test("scroll direction getters works correctly", () {
    controller.setScrollingDirection(ScrollDirection.forward);
    expect(controller.isScrollingForward, isTrue);
    expect(controller.isScrollingReverse, isFalse);
    expect(controller.isScrollIdle, isFalse);
    controller.setScrollingDirection(ScrollDirection.idle);
    expect(controller.isScrollingForward, isFalse);
    expect(controller.isScrollingReverse, isFalse);
    expect(controller.isScrollIdle, isTrue);
    controller.setScrollingDirection(ScrollDirection.reverse);
    expect(controller.isScrollingForward, isFalse);
    expect(controller.isScrollingReverse, isTrue);
    expect(controller.isScrollIdle, isFalse);
  });
}
