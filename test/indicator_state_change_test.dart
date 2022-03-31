import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("State getters works correctly", () {
    final change = IndicatorStateChange(
      IndicatorState.dragging,
      IndicatorState.armed,
    );
    expect(change.currentState, equals(IndicatorState.dragging));
    expect(change.newState, equals(IndicatorState.armed));
  });

  test('didChange method works correctly.', () {
    var change = IndicatorStateChange(
      IndicatorState.idle,
      IndicatorState.idle,
    );
    expect(change.didChange(), isFalse);
    change = IndicatorStateChange(
      IndicatorState.idle,
      IndicatorState.dragging,
    );
    expect(
      change.didChange(),
      isTrue,
    );
    expect(
      change.didChange(
        from: IndicatorState.idle,
        to: IndicatorState.dragging,
      ),
      isTrue,
    );
    expect(
      change.didChange(
        to: IndicatorState.dragging,
      ),
      isTrue,
    );
    expect(
      change.didChange(
        from: IndicatorState.idle,
      ),
      isTrue,
    );
    expect(
      change.didChange(
        from: IndicatorState.dragging,
      ),
      isFalse,
    );
    expect(
      change.didChange(
        to: IndicatorState.idle,
      ),
      isFalse,
    );
  });

  test("toString method works correctly", () {
    var change = IndicatorStateChange(
      IndicatorState.dragging,
      IndicatorState.armed,
    );
    expect(
      change.toString(),
      'IndicatorStateChange(dragging → armed)',
    );
    change = IndicatorStateChange(
      IndicatorState.loading,
      IndicatorState.complete,
    );
    expect(
      change.toString(),
      'IndicatorStateChange(loading → complete)',
    );
  });
}
