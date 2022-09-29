enum IndicatorSide {
  left,
  top,
  right,
  bottom,

  none,
}

extension IndicatorSideGetters on IndicatorSide {
  bool get isLeft => this == IndicatorSide.left;
  bool get isTop => this == IndicatorSide.top;
  bool get isRight => this == IndicatorSide.right;
  bool get isBottom => this == IndicatorSide.bottom;

  bool get isNone => this == IndicatorSide.none;
}
