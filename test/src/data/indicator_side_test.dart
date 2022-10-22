import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('IndicatorSideGetters - left', () async {
    const left = IndicatorSide.left;
    expect(left.isLeft, isTrue);
    expect(left.isTop, isFalse);
    expect(left.isRight, isFalse);
    expect(left.isBottom, isFalse);
    expect(left.isNone, isFalse);
  });

  test('IndicatorSideGetters - right', () async {
    const right = IndicatorSide.right;
    expect(right.isLeft, isFalse);
    expect(right.isTop, isFalse);
    expect(right.isRight, isTrue);
    expect(right.isBottom, isFalse);
    expect(right.isNone, isFalse);
  });

  test('IndicatorSideGetters - top', () async {
    const right = IndicatorSide.top;
    expect(right.isLeft, isFalse);
    expect(right.isTop, isTrue);
    expect(right.isRight, isFalse);
    expect(right.isBottom, isFalse);
    expect(right.isNone, isFalse);
  });

  test('IndicatorSideGetters - bottom', () async {
    const right = IndicatorSide.bottom;
    expect(right.isLeft, isFalse);
    expect(right.isTop, isFalse);
    expect(right.isRight, isFalse);
    expect(right.isBottom, isTrue);
    expect(right.isNone, isFalse);
  });

  test('IndicatorSideGetters - none', () async {
    const none = IndicatorSide.none;
    expect(none.isLeft, isFalse);
    expect(none.isTop, isFalse);
    expect(none.isRight, isFalse);
    expect(none.isBottom, isFalse);
    expect(none.isNone, isTrue);
  });
}
