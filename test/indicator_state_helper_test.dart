import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late IndicatorStateHelper helper;

  setUp(() {
    helper = IndicatorStateHelper();
  });

  test("state getters works correctly", () {
    expect(helper.state, equals(IndicatorState.idle));
    expect(helper.isIdle, isTrue);
    expect(helper.isDragging, isFalse);
    expect(helper.isHiding, isFalse);
    expect(helper.isArmed, isFalse);
    expect(helper.isLoading, isFalse);
    expect(helper.isComplete, isFalse);

    helper.update(IndicatorState.dragging);
    expect(helper.isIdle, isFalse);
    expect(helper.isDragging, isTrue);
    expect(helper.isHiding, isFalse);
    expect(helper.isArmed, isFalse);
    expect(helper.isLoading, isFalse);
    expect(helper.isComplete, isFalse);

    helper.update(IndicatorState.hiding);
    expect(helper.isIdle, isFalse);
    expect(helper.isDragging, isFalse);
    expect(helper.isHiding, isTrue);
    expect(helper.isArmed, isFalse);
    expect(helper.isLoading, isFalse);
    expect(helper.isComplete, isFalse);

    helper.update(IndicatorState.armed);
    expect(helper.isIdle, isFalse);
    expect(helper.isDragging, isFalse);
    expect(helper.isHiding, isFalse);
    expect(helper.isArmed, isTrue);
    expect(helper.isLoading, isFalse);
    expect(helper.isComplete, isFalse);

    helper.update(IndicatorState.loading);
    expect(helper.isIdle, isFalse);
    expect(helper.isDragging, isFalse);
    expect(helper.isHiding, isFalse);
    expect(helper.isArmed, isFalse);
    expect(helper.isLoading, isTrue);
    expect(helper.isComplete, isFalse);

    helper.update(IndicatorState.complete);
    expect(helper.isIdle, isFalse);
    expect(helper.isDragging, isFalse);
    expect(helper.isHiding, isFalse);
    expect(helper.isArmed, isFalse);
    expect(helper.isLoading, isFalse);
    expect(helper.isComplete, isTrue);
  });

  test("previous state getters works correctly", () {
    expect(helper.state, equals(IndicatorState.idle));
    expect(helper.wasIdle, isTrue);
    expect(helper.wasDragging, isFalse);
    expect(helper.wasHiding, isFalse);
    expect(helper.wasArmed, isFalse);
    expect(helper.wasLoading, isFalse);
    expect(helper.wasComplete, isFalse);

    helper.update(IndicatorState.dragging);
    expect(helper.wasIdle, isTrue);
    expect(helper.wasDragging, isFalse);
    expect(helper.wasHiding, isFalse);
    expect(helper.wasArmed, isFalse);
    expect(helper.wasLoading, isFalse);
    expect(helper.wasComplete, isFalse);

    helper.update(IndicatorState.hiding);
    expect(helper.wasIdle, isFalse);
    expect(helper.wasDragging, isTrue);
    expect(helper.wasHiding, isFalse);
    expect(helper.wasArmed, isFalse);
    expect(helper.wasLoading, isFalse);
    expect(helper.wasComplete, isFalse);

    helper.update(IndicatorState.armed);
    expect(helper.wasIdle, isFalse);
    expect(helper.wasDragging, isFalse);
    expect(helper.wasHiding, isTrue);
    expect(helper.wasArmed, isFalse);
    expect(helper.wasLoading, isFalse);
    expect(helper.wasComplete, isFalse);

    helper.update(IndicatorState.loading);
    expect(helper.wasIdle, isFalse);
    expect(helper.wasDragging, isFalse);
    expect(helper.wasHiding, isFalse);
    expect(helper.wasArmed, isTrue);
    expect(helper.wasLoading, isFalse);
    expect(helper.wasComplete, isFalse);

    helper.update(IndicatorState.complete);
    expect(helper.wasIdle, isFalse);
    expect(helper.wasDragging, isFalse);
    expect(helper.wasHiding, isFalse);
    expect(helper.wasArmed, isFalse);
    expect(helper.wasLoading, isTrue);
    expect(helper.wasComplete, isFalse);

    helper.update(IndicatorState.idle);
    expect(helper.wasIdle, isFalse);
    expect(helper.wasDragging, isFalse);
    expect(helper.wasHiding, isFalse);
    expect(helper.wasArmed, isFalse);
    expect(helper.wasLoading, isFalse);
    expect(helper.wasComplete, isTrue);
  });

  test("update method changes state and proviousState", () {
    expect(helper.state, equals(IndicatorState.idle));
    expect(helper.previousState, equals(IndicatorState.idle));

    helper.update(IndicatorState.dragging);
    expect(helper.state, equals(IndicatorState.dragging));
    expect(helper.previousState, equals(IndicatorState.idle));

    helper.update(IndicatorState.armed);
    expect(helper.state, equals(IndicatorState.armed));
    expect(helper.previousState, equals(IndicatorState.dragging));

    helper.update(IndicatorState.hiding);
    expect(helper.state, equals(IndicatorState.hiding));
    expect(helper.previousState, equals(IndicatorState.armed));

    helper.update(IndicatorState.loading);
    expect(helper.state, equals(IndicatorState.loading));
    expect(helper.previousState, equals(IndicatorState.hiding));

    helper.update(IndicatorState.complete);
    expect(helper.state, equals(IndicatorState.complete));
    expect(helper.previousState, equals(IndicatorState.loading));

    helper.update(IndicatorState.idle);
    expect(helper.state, equals(IndicatorState.idle));
    expect(helper.previousState, equals(IndicatorState.complete));

    helper.update(IndicatorState.idle);
    expect(helper.state, equals(IndicatorState.idle));
    expect(helper.previousState, equals(IndicatorState.idle));

    helper.update(IndicatorState.idle);
    expect(helper.state, equals(IndicatorState.idle));
    expect(helper.previousState, equals(IndicatorState.idle));
  });

  group('didStateChange works correctly', () {
    test('return true when state have changed', () {
      expect(helper.didStateChange(), isFalse);
      helper.update(IndicatorState.idle);
      expect(helper.didStateChange(), isFalse);
      helper.update(IndicatorState.dragging);
      expect(helper.didStateChange(), isTrue);
      helper.update(IndicatorState.dragging);
      expect(helper.didStateChange(), isFalse);
      helper.update(IndicatorState.armed);
      expect(helper.didStateChange(), isTrue);
      helper.update(IndicatorState.armed);
      expect(helper.didStateChange(), isFalse);
      helper.update(IndicatorState.hiding);
      expect(helper.didStateChange(), isTrue);
      helper.update(IndicatorState.hiding);
      expect(helper.didStateChange(), isFalse);
      helper.update(IndicatorState.loading);
      expect(helper.didStateChange(), isTrue);
      helper.update(IndicatorState.loading);
      expect(helper.didStateChange(), isFalse);
      helper.update(IndicatorState.complete);
      expect(helper.didStateChange(), isTrue);
      helper.update(IndicatorState.complete);
      expect(helper.didStateChange(), isFalse);
    });

    test('return true when state have changed "from"', () {
      expect(helper.didStateChange(from: IndicatorState.idle), isFalse);
      helper.update(IndicatorState.idle);
      expect(helper.didStateChange(from: IndicatorState.idle), isFalse);
      helper.update(IndicatorState.dragging);
      expect(helper.didStateChange(from: IndicatorState.idle), isTrue);
      helper.update(IndicatorState.armed);
      expect(helper.didStateChange(from: IndicatorState.dragging), isTrue);
      helper.update(IndicatorState.hiding);
      expect(helper.didStateChange(from: IndicatorState.armed), isTrue);
      helper.update(IndicatorState.loading);
      expect(helper.didStateChange(from: IndicatorState.hiding), isTrue);
      helper.update(IndicatorState.complete);
      expect(helper.didStateChange(from: IndicatorState.loading), isTrue);
      helper.update(IndicatorState.idle);
      expect(helper.didStateChange(from: IndicatorState.complete), isTrue);

      helper.update(IndicatorState.idle);
      expect(helper.didStateChange(from: IndicatorState.complete), isFalse);
    });

    test('return true when state have changed "to"', () {
      expect(helper.didStateChange(to: IndicatorState.idle), isFalse);
      expect(helper.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(helper.didStateChange(to: IndicatorState.armed), isFalse);
      expect(helper.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(helper.didStateChange(to: IndicatorState.loading), isFalse);
      expect(helper.didStateChange(to: IndicatorState.complete), isFalse);

      helper.update(IndicatorState.idle);
      expect(helper.didStateChange(to: IndicatorState.idle), isFalse);
      expect(helper.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(helper.didStateChange(to: IndicatorState.armed), isFalse);
      expect(helper.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(helper.didStateChange(to: IndicatorState.loading), isFalse);
      expect(helper.didStateChange(to: IndicatorState.complete), isFalse);

      helper.update(IndicatorState.dragging);
      expect(helper.didStateChange(to: IndicatorState.idle), isFalse);
      expect(helper.didStateChange(to: IndicatorState.dragging), isTrue);
      expect(helper.didStateChange(to: IndicatorState.armed), isFalse);
      expect(helper.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(helper.didStateChange(to: IndicatorState.loading), isFalse);
      expect(helper.didStateChange(to: IndicatorState.complete), isFalse);

      helper.update(IndicatorState.armed);
      expect(helper.didStateChange(to: IndicatorState.idle), isFalse);
      expect(helper.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(helper.didStateChange(to: IndicatorState.armed), isTrue);
      expect(helper.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(helper.didStateChange(to: IndicatorState.loading), isFalse);
      expect(helper.didStateChange(to: IndicatorState.complete), isFalse);

      helper.update(IndicatorState.hiding);
      expect(helper.didStateChange(to: IndicatorState.idle), isFalse);
      expect(helper.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(helper.didStateChange(to: IndicatorState.armed), isFalse);
      expect(helper.didStateChange(to: IndicatorState.hiding), isTrue);
      expect(helper.didStateChange(to: IndicatorState.loading), isFalse);
      expect(helper.didStateChange(to: IndicatorState.complete), isFalse);

      helper.update(IndicatorState.loading);
      expect(helper.didStateChange(to: IndicatorState.idle), isFalse);
      expect(helper.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(helper.didStateChange(to: IndicatorState.armed), isFalse);
      expect(helper.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(helper.didStateChange(to: IndicatorState.loading), isTrue);
      expect(helper.didStateChange(to: IndicatorState.complete), isFalse);

      helper.update(IndicatorState.complete);
      expect(helper.didStateChange(to: IndicatorState.idle), isFalse);
      expect(helper.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(helper.didStateChange(to: IndicatorState.armed), isFalse);
      expect(helper.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(helper.didStateChange(to: IndicatorState.loading), isFalse);
      expect(helper.didStateChange(to: IndicatorState.complete), isTrue);

      helper.update(IndicatorState.idle);
      expect(helper.didStateChange(to: IndicatorState.idle), isTrue);
      expect(helper.didStateChange(to: IndicatorState.dragging), isFalse);
      expect(helper.didStateChange(to: IndicatorState.armed), isFalse);
      expect(helper.didStateChange(to: IndicatorState.hiding), isFalse);
      expect(helper.didStateChange(to: IndicatorState.loading), isFalse);
      expect(helper.didStateChange(to: IndicatorState.complete), isFalse);
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
          helper.didStateChange(
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
          helper.didStateChange(
            from: state,
            to: IndicatorState.idle,
          ),
          isFalse,
        );
      }

      expect(
        helper.didStateChange(
          from: IndicatorState.idle,
          to: IndicatorState.idle,
        ),
        isTrue,
      );
    });
  });
}
