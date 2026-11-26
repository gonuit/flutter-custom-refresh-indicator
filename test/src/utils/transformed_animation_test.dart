import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AnimationController parent;

  TransformedAnimation buildAnimation({
    double fromMin = 0.0,
    double fromMax = 1.5,
    double toMin = 0.0,
    double toMax = 1.0,
  }) =>
      TransformedAnimation(
        parent: parent,
        fromMin: fromMin,
        fromMax: fromMax,
        toMin: toMin,
        toMax: toMax,
      );

  setUp(() {
    parent = AnimationController(
      vsync: const TestVSync(),
      lowerBound: 0.0,
      upperBound: 1.5,
    );
  });

  tearDown(() => parent.dispose());

  test('maps the parent range onto the target range', () {
    final animation = buildAnimation();

    parent.value = 0.0;
    expect(animation.value, 0.0);

    parent.value = 0.75;
    expect(animation.value, 0.5);

    parent.value = 1.5;
    expect(animation.value, 1.0);
  });

  test('maps onto a range that does not start at zero', () {
    final animation = buildAnimation(toMin: 10.0, toMax: 20.0);

    parent.value = 0.0;
    expect(animation.value, 10.0);

    parent.value = 0.75;
    expect(animation.value, 15.0);

    parent.value = 1.5;
    expect(animation.value, 20.0);
  });

  test('does not clamp values outside of the source range', () {
    final animation = buildAnimation(fromMin: 0.0, fromMax: 1.0);

    parent.value = 1.5;

    expect(animation.value, 1.5);
  });

  test('exposes the parent', () {
    final animation = buildAnimation();

    expect(animation.parent, parent);
    expect(animation.status, parent.status);
  });

  test('toString describes the target range', () {
    final animation = buildAnimation(toMin: 10.0, toMax: 20.0);

    expect(animation.toString(), 'TransformedAnimation(min: 10.0, max: 20.0)');
  });

  test('asserts that the range bounds are ordered', () {
    expect(
      () => buildAnimation(fromMin: 1.0, fromMax: 1.0),
      throwsAssertionError,
    );
    expect(
      () => buildAnimation(fromMin: 2.0, fromMax: 1.0),
      throwsAssertionError,
    );
    expect(() => buildAnimation(toMin: 1.0, toMax: 1.0), throwsAssertionError);
    expect(() => buildAnimation(toMin: 2.0, toMax: 1.0), throwsAssertionError);
  });

  test('IndicatorController exposes the transformed animations', () {
    final controller = IndicatorController();
    addTearDown(controller.dispose);

    final clamped = controller.clamp(0.0, 1.0);
    final transformed = controller.transform(0.0, 10.0);
    final normalized = controller.normalize();

    controller.setValue(1.5);

    expect(clamped.value, 1.0);
    expect(transformed.value, 10.0);
    expect(normalized.value, 1.0);

    controller.setValue(0.75);

    expect(clamped.value, 0.75);
    expect(transformed.value, 5.0);
    expect(normalized.value, 0.5);
  });
}
