/// Used to configure how [CustomRefreshIndicator] can be triggered.
enum IndicatorTriggerMode {
  /// The indicator can be triggered regardless of the scroll position
  /// of the [Scrollable] when the drag starts.
  anywhere,

  /// The indicator can only be triggered if the [Scrollable] is at the edge
  /// when the drag starts.
  onEdge,
}
