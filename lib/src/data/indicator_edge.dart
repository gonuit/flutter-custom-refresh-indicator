enum IndicatorEdge {
  leading,
  trailing,
}

extension IndicatorEdgeGetters on IndicatorEdge {
  bool get isTrailing => this == IndicatorEdge.trailing;
  bool get isLeading => this == IndicatorEdge.leading;
}
