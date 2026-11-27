/// {@template custom_refresh_indicator.indicator_trigger}
/// Defines the trigger for the pull to refresh gesture.
/// {@endtemplate}
///
/// **startEdge**:
/// {@macro custom_refresh_indicator.indicator_trigger.leading}
///
/// **endEdge**:
/// {@macro custom_refresh_indicator.indicator_trigger.trailing}
///
/// **bothEdges**:
/// {@macro custom_refresh_indicator.indicator_trigger.both}
enum IndicatorTrigger {
  /// {@template custom_refresh_indicator.indicator_trigger.leading}
  /// Pull to refresh can be triggered only from the **leading** edge of the list.
  /// Mostly top side, but can be bottom for reversed ListView
  /// (with *reverse* argument set to true).
  /// {@endtemplate}
  leadingEdge,

  /// {@template custom_refresh_indicator.indicator_trigger.trailing}
  /// Pull to refresh can be triggered only from the **trailing** edge of the list.
  /// Mostly bottom, but can be top for reversed ListView
  /// (with *reverse* argument set to true).
  /// {@endtemplate}
  trailingEdge,

  /// {@template custom_refresh_indicator.indicator_trigger.both}
  /// Pull to refresh can be triggered from **both edges** of the list.
  /// {@endtemplate}
  bothEdges,
}
