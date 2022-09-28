enum IndicatorEdge {
  begin,
  end,
  undetermined,
}

extension IndicatorSideGetters on IndicatorEdge {
  bool get isUndetermined => this == IndicatorEdge.undetermined;
  bool get isBottom => this == IndicatorEdge.end;
  bool get isTop => this == IndicatorEdge.begin;
}
