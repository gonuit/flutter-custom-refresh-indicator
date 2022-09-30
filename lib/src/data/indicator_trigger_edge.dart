/// {@template custom_refresh_indicator.indicator_trigger}
/// Defines the trigger for the pull to refresh gesture.
/// {@endtemplate}
///
/// **startEdge**:
/// {@macro custom_refresh_indicator.indicator_trigger.start}
///
/// **endEdge**:
/// {@macro custom_refresh_indicator.indicator_trigger.end}
///
/// **bothEdges**:
/// {@macro custom_refresh_indicator.indicator_trigger.both}
enum IndicatorTrigger {
  /// {@template custom_refresh_indicator.indicator_trigger.start}
  /// Pull to refresh can be triggered only from the **start** edge of the list.
  /// Mostly top side, but can be bottom for reversed ListView
  /// (with *reverse* argument set to true).
  /// {@endtemplate}
  startEdge,

  /// {@template custom_refresh_indicator.indicator_trigger.end}
  /// Pull to refresh can be triggered only from the **end** edge of the list.
  /// Mostly bottom, but can be top for reversed ListView
  /// (with *reverse* argument set to true).
  /// {@endtemplate}
  endEdge,

  /// {@template custom_refresh_indicator.indicator_trigger.both}
  /// Pull to refresh can be triggered from **both edges** of the list.
  /// {@endtemplate}
  bothEdges,
}
