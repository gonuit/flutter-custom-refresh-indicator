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
    expect(controller.previousState, equals(IndicatorState.idle));
    expect(controller.value, equals(0.0));
    expect(controller.direction, AxisDirection.down);
    expect(controller.isIdle, isTrue);
    expect(controller.isDragging, isFalse);
    expect(controller.isHiding, isFalse);
    expect(controller.isArmed, isFalse);
    expect(controller.isLoading, isFalse);
    expect(controller.isComplete, isFalse);
    expect(controller.wasIdle, isTrue);
    expect(controller.wasDragging, isFalse);
    expect(controller.wasHiding, isFalse);
    expect(controller.wasArmed, isFalse);
    expect(controller.wasLoading, isFalse);
    expect(controller.wasComplete, isFalse);
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

  test("previous state getters works correctly", () {
    expect(controller.state, equals(IndicatorState.idle));
    expect(controller.wasIdle, isTrue);
    expect(controller.wasDragging, isFalse);
    expect(controller.wasHiding, isFalse);
    expect(controller.wasArmed, isFalse);
    expect(controller.wasLoading, isFalse);
    expect(controller.wasComplete, isFalse);

    controller.setIndicatorState(IndicatorState.dragging);
    expect(controller.wasIdle, isTrue);
    expect(controller.wasDragging, isFalse);
    expect(controller.wasHiding, isFalse);
    expect(controller.wasArmed, isFalse);
    expect(controller.wasLoading, isFalse);
    expect(controller.wasComplete, isFalse);

    controller.setIndicatorState(IndicatorState.hiding);
    expect(controller.wasIdle, isFalse);
    expect(controller.wasDragging, isTrue);
    expect(controller.wasHiding, isFalse);
    expect(controller.wasArmed, isFalse);
    expect(controller.wasLoading, isFalse);
    expect(controller.wasComplete, isFalse);

    controller.setIndicatorState(IndicatorState.armed);
    expect(controller.wasIdle, isFalse);
    expect(controller.wasDragging, isFalse);
    expect(controller.wasHiding, isTrue);
    expect(controller.wasArmed, isFalse);
    expect(controller.wasLoading, isFalse);
    expect(controller.wasComplete, isFalse);

    controller.setIndicatorState(IndicatorState.loading);
    expect(controller.wasIdle, isFalse);
    expect(controller.wasDragging, isFalse);
    expect(controller.wasHiding, isFalse);
    expect(controller.wasArmed, isTrue);
    expect(controller.wasLoading, isFalse);
    expect(controller.wasComplete, isFalse);

    controller.setIndicatorState(IndicatorState.complete);
    expect(controller.wasIdle, isFalse);
    expect(controller.wasDragging, isFalse);
    expect(controller.wasHiding, isFalse);
    expect(controller.wasArmed, isFalse);
    expect(controller.wasLoading, isTrue);
    expect(controller.wasComplete, isFalse);

    controller.setIndicatorState(IndicatorState.idle);
    expect(controller.wasIdle, isFalse);
    expect(controller.wasDragging, isFalse);
    expect(controller.wasHiding, isFalse);
    expect(controller.wasArmed, isFalse);
    expect(controller.wasLoading, isFalse);
    expect(controller.wasComplete, isTrue);
  });

  test(
      "setIndicatorState method changes "
      "state, proviousState and notifies listeners", () {
    expect(listener.called, equals(0));
    expect(controller.state, equals(IndicatorState.idle));
    expect(controller.previousState, equals(IndicatorState.idle));

    controller.setIndicatorState(IndicatorState.dragging);
    expect(listener.called, equals(1));
    expect(controller.state, equals(IndicatorState.dragging));
    expect(controller.previousState, equals(IndicatorState.idle));

    controller.setIndicatorState(IndicatorState.armed);
    expect(listener.called, equals(2));
    expect(controller.state, equals(IndicatorState.armed));
    expect(controller.previousState, equals(IndicatorState.dragging));

    controller.setIndicatorState(IndicatorState.hiding);
    expect(listener.called, equals(3));
    expect(controller.state, equals(IndicatorState.hiding));
    expect(controller.previousState, equals(IndicatorState.armed));

    controller.setIndicatorState(IndicatorState.loading);
    expect(listener.called, equals(4));
    expect(controller.state, equals(IndicatorState.loading));
    expect(controller.previousState, equals(IndicatorState.hiding));

    controller.setIndicatorState(IndicatorState.complete);
    expect(listener.called, equals(5));
    expect(controller.state, equals(IndicatorState.complete));
    expect(controller.previousState, equals(IndicatorState.loading));

    controller.setIndicatorState(IndicatorState.idle);
    expect(listener.called, equals(6));
    expect(controller.state, equals(IndicatorState.idle));
    expect(controller.previousState, equals(IndicatorState.complete));

    controller.setIndicatorState(IndicatorState.idle);
    expect(listener.called, equals(7));
    expect(controller.state, equals(IndicatorState.idle));
    expect(controller.previousState, equals(IndicatorState.idle));

    controller.setIndicatorState(IndicatorState.idle);
    expect(listener.called, equals(8));
    expect(controller.state, equals(IndicatorState.idle));
    expect(controller.previousState, equals(IndicatorState.idle));
  });

  test('notifyListeners method shift state', () {
    expect(listener.called, equals(0));
    expect(controller.state, equals(IndicatorState.idle));
    expect(controller.previousState, equals(IndicatorState.idle));

    controller.setIndicatorState(IndicatorState.dragging);
    expect(listener.called, equals(1));
    expect(controller.state, equals(IndicatorState.dragging));
    expect(controller.previousState, equals(IndicatorState.idle));

    controller.notifyListeners();
    expect(listener.called, equals(2));
    expect(controller.state, equals(IndicatorState.dragging));
    expect(controller.previousState, equals(IndicatorState.dragging));

    controller.setIndicatorState(IndicatorState.armed);
    expect(listener.called, equals(3));
    expect(controller.state, equals(IndicatorState.armed));
    expect(controller.previousState, equals(IndicatorState.dragging));

    controller.notifyListeners(shiftState: false);
    expect(listener.called, equals(4));
    expect(controller.state, equals(IndicatorState.armed));
    expect(controller.previousState, equals(IndicatorState.dragging));

    controller.notifyListeners(shiftState: true);
    expect(listener.called, equals(5));
    expect(controller.state, equals(IndicatorState.armed));
    expect(controller.previousState, equals(IndicatorState.armed));
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
  group('didStateChange works correctly', () {
    test('return true when state have changed', () {
      expect(controller.didStateChange(), isFalse);
      controller.setIndicatorState(IndicatorState.idle);
      expect(controller.didStateChange(), isFalse);
      controller.setIndicatorState(IndicatorState.dragging);
      expect(controller.didStateChange(), isTrue);
      controller.setIndicatorState(IndicatorState.dragging);
      expect(controller.didStateChange(), isFalse);
      controller.setIndicatorState(IndicatorState.armed);
      expect(controller.didStateChange(), isTrue);
      controller.setIndicatorState(IndicatorState.armed);
      expect(controller.didStateChange(), isFalse);
      controller.setIndicatorState(IndicatorState.hiding);
      expect(controller.didStateChange(), isTrue);
      controller.setIndicatorState(IndicatorState.hiding);
      expect(controller.didStateChange(), isFalse);
      controller.setIndicatorState(IndicatorState.loading);
      expect(controller.didStateChange(), isTrue);
      controller.setIndicatorState(IndicatorState.loading);
      expect(controller.didStateChange(), isFalse);
      controller.setIndicatorState(IndicatorState.complete);
      expect(controller.didStateChange(), isTrue);
      controller.setIndicatorState(IndicatorState.complete);
      expect(controller.didStateChange(), isFalse);
    });

    test('return true when state have changed "from"', () {
      expect(controller.didStateChange(from: IndicatorState.idle), isFalse);
      controller.setIndicatorState(IndicatorState.idle);
      expect(controller.didStateChange(from: IndicatorState.idle), isFalse);
      controller.setIndicatorState(IndicatorState.dragging);
      expect(controller.didStateChange(from: IndicatorState.idle), isTrue);
      controller.setIndicatorState(IndicatorState.armed);
      expect(controller.didStateChange(from: IndicatorState.dragging), isTrue);
      controller.setIndicatorState(IndicatorState.hiding);
      expect(controller.didStateChange(from: IndicatorState.armed), isTrue);
      controller.setIndicatorState(IndicatorState.loading);
      expect(controller.didStateChange(from: IndicatorState.hiding), isTrue);
      controller.setIndicatorState(IndicatorState.complete);
      expect(controller.didStateChange(from: IndicatorState.loading), isTrue);
      controller.setIndicatorState(IndicatorState.idle);
      expect(controller.didStateChange(from: IndicatorState.complete), isTrue);

      controller.setIndicatorState(IndicatorState.idle);
      expect(controller.didStateChange(from: IndicatorState.complete), isFalse);
    });

    test('return true when state have changed "to"', () {
      expect(controller.didStateChange(to: IndicatorState.idle), isFalse);
      expect(controller.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(controller.didStateChange(to: IndicatorState.armed), isFalse);
      expect(controller.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(controller.didStateChange(to: IndicatorState.loading), isFalse);
      expect(controller.didStateChange(to: IndicatorState.complete), isFalse);

      controller.setIndicatorState(IndicatorState.idle);
      expect(controller.didStateChange(to: IndicatorState.idle), isFalse);
      expect(controller.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(controller.didStateChange(to: IndicatorState.armed), isFalse);
      expect(controller.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(controller.didStateChange(to: IndicatorState.loading), isFalse);
      expect(controller.didStateChange(to: IndicatorState.complete), isFalse);

      controller.setIndicatorState(IndicatorState.dragging);
      expect(controller.didStateChange(to: IndicatorState.idle), isFalse);
      expect(controller.didStateChange(to: IndicatorState.dragging), isTrue);
      expect(controller.didStateChange(to: IndicatorState.armed), isFalse);
      expect(controller.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(controller.didStateChange(to: IndicatorState.loading), isFalse);
      expect(controller.didStateChange(to: IndicatorState.complete), isFalse);

      controller.setIndicatorState(IndicatorState.armed);
      expect(controller.didStateChange(to: IndicatorState.idle), isFalse);
      expect(controller.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(controller.didStateChange(to: IndicatorState.armed), isTrue);
      expect(controller.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(controller.didStateChange(to: IndicatorState.loading), isFalse);
      expect(controller.didStateChange(to: IndicatorState.complete), isFalse);

      controller.setIndicatorState(IndicatorState.hiding);
      expect(controller.didStateChange(to: IndicatorState.idle), isFalse);
      expect(controller.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(controller.didStateChange(to: IndicatorState.armed), isFalse);
      expect(controller.didStateChange(to: IndicatorState.hiding), isTrue);
      expect(controller.didStateChange(to: IndicatorState.loading), isFalse);
      expect(controller.didStateChange(to: IndicatorState.complete), isFalse);

      controller.setIndicatorState(IndicatorState.loading);
      expect(controller.didStateChange(to: IndicatorState.idle), isFalse);
      expect(controller.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(controller.didStateChange(to: IndicatorState.armed), isFalse);
      expect(controller.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(controller.didStateChange(to: IndicatorState.loading), isTrue);
      expect(controller.didStateChange(to: IndicatorState.complete), isFalse);

      controller.setIndicatorState(IndicatorState.complete);
      expect(controller.didStateChange(to: IndicatorState.idle), isFalse);
      expect(controller.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(controller.didStateChange(to: IndicatorState.armed), isFalse);
      expect(controller.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(controller.didStateChange(to: IndicatorState.loading), isFalse);
      expect(controller.didStateChange(to: IndicatorState.complete), isTrue);

      controller.setIndicatorState(IndicatorState.idle);
      expect(controller.didStateChange(to: IndicatorState.idle), isTrue);
      expect(controller.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(controller.didStateChange(to: IndicatorState.armed), isFalse);
      expect(controller.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(controller.didStateChange(to: IndicatorState.loading), isFalse);
      expect(controller.didStateChange(to: IndicatorState.complete), isFalse);
    });

    test('return true when state have changed "from" "to"', () {
      final states = [
        IndicatorState.idle,
        IndicatorState.dragging,
        IndicatorState.armed,
        IndicatorState.hiding,
        IndicatorState.loading,
        IndicatorState.complete,
      ];
      for (final state in states.where(
        (state) => state != IndicatorState.idle,
      )) {
        expect(
          controller.didStateChange(
            from: IndicatorState.idle,
            to: state,
          ),
          isFalse,
        );
      }

      for (final state in states.where(
        (state) => state != IndicatorState.idle,
      )) {
        expect(
          controller.didStateChange(
            from: state,
            to: IndicatorState.idle,
          ),
          isFalse,
        );
      }

      expect(
        controller.didStateChange(
          from: IndicatorState.idle,
          to: IndicatorState.idle,
        ),
        isTrue,
      );
    });
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
