/// {@template custom_refresh_indicator.indicator_trigger_edge}
/// Defines the edge of a [Scrollable] that can trigger the pull to refresh gesture.
/// {@endtemplate}
///
/// **begin**:
/// {@macro custom_refresh_indicator.indicator_trigger_edge.begin}
///
/// **end**:
/// {@macro custom_refresh_indicator.indicator_trigger_edge.end}
///
/// **both**:
/// {@macro custom_refresh_indicator.indicator_trigger_edge.both}
enum IndicatorTriggerEdge {
  /// {@template custom_refresh_indicator.indicator_trigger_edge.begin}
  /// Pull to refresh can be triggered from the **begin** of the list.
  /// Mostly top side, but can be bottom for reversed ListView
  /// (with *reverse* argument set to true).
  /// {@endtemplate}
  begin,

  /// {@template custom_refresh_indicator.indicator_trigger_edge.end}
  /// Pull to refresh can be triggered from the **end** of the list.
  /// Mostly bottom, but can be top for reversed ListView
  /// (with *reverse* argument set to true).
  /// {@endtemplate}
  end,

  /// {@template custom_refresh_indicator.indicator_trigger_edge.both}
  /// Pull to refresh can be triggered from **both sides** of the list.
  /// {@endtemplate}
  both,
}
