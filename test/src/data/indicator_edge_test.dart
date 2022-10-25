import 'package:custom_refresh_indicator/src/data/indicator_edge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('IndicatorEdgeGetters - trailing', () async {
    const end = IndicatorEdge.trailing;
    expect(end.isLeading, isFalse);
    expect(end.isTrailing, isTrue);
  });

  test('IndicatorEdgeGetters - leading', () async {
    const start = IndicatorEdge.leading;
    expect(start.isLeading, isTrue);
    expect(start.isTrailing, isFalse);
  });
}
