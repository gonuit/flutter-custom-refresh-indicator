enum IndicatorEdge {
  start,
  end,
}

extension IndicatorEdgeGetters on IndicatorEdge {
  bool get isEnd => this == IndicatorEdge.end;
  bool get isStart => this == IndicatorEdge.start;
}
