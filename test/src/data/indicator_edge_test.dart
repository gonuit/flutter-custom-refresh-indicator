import 'package:custom_refresh_indicator/src/data/indicator_edge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('IndicatorEdgeGetters - end', () async {
    const end = IndicatorEdge.end;
    expect(end.isStart, isFalse);
    expect(end.isEnd, isTrue);
  });

  test('IndicatorEdgeGetters - start', () async {
    const start = IndicatorEdge.start;
    expect(start.isStart, isTrue);
    expect(start.isEnd, isFalse);
  });
}
