import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AnimationController parent;

  setUp(() {
    parent = AnimationController(vsync: const TestVSync());
  });

  tearDown(() => parent.dispose());

  test('value is clamped to the given range', () {
    final animation = ClampedAnimation(parent: parent, min: 0.25, max: 0.75);

    parent.value = 0.0;
    expect(animation.value, 0.25);

    parent.value = 0.5;
    expect(animation.value, 0.5);

    parent.value = 1.0;
    expect(animation.value, 0.75);
  });

  test('exposes the parent and its status', () {
    final animation = ClampedAnimation(parent: parent, min: 0.0, max: 1.0);

    expect(animation.parent, parent);
    expect(animation.status, parent.status);

    parent.value = 1.0;

    expect(animation.status, AnimationStatus.completed);
  });

  test('notifies listeners through the parent', () {
    final animation = ClampedAnimation(parent: parent, min: 0.0, max: 1.0);
    var notifications = 0;
    animation.addListener(() => notifications++);
    addTearDown(() => animation.removeListener(() {}));

    parent.value = 0.5;

    expect(notifications, 1);
  });

  test('toString describes the range', () {
    final animation = ClampedAnimation(parent: parent, min: 0.25, max: 0.75);

    expect(animation.toString(), '$parent(min: 0.25, max: 0.75)');
  });

  test('asserts that min is less than max', () {
    expect(
      () => ClampedAnimation(parent: parent, min: 1.0, max: 1.0),
      throwsAssertionError,
    );
    expect(
      () => ClampedAnimation(parent: parent, min: 1.0, max: 0.0),
      throwsAssertionError,
    );
  });
}
