enum IndicatorEdge {
  start,
  end,
  undetermined,
}

extension IndicatorEdgeGetters on IndicatorEdge {
  bool get isUndetermined => this == IndicatorEdge.undetermined;
  bool get isEnd => this == IndicatorEdge.end;
  bool get isStart => this == IndicatorEdge.start;
}
