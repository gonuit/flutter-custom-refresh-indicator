/// Describes state of CustomRefreshIndicator widget.
enum IndicatorState {
  /// {@template custom_refresh_indicator.indicator_state.idle}
  /// In this state, the indicator is not visible.
  /// No user action is performed. Value remains at *0.0*.
  /// {@endtemplate}
  idle,

  /// {@template custom_refresh_indicator.indicator_state.dragging}
  /// The user starts scrolling/dragging the pointer to refresh.
  /// Releasing the pointer in this state will not trigger
  /// the *onRefresh* function. The controller value changes
  /// from *0.0* to *1.0*.
  /// {@endtemplate}
  dragging,

  /// {@template custom_refresh_indicator.indicator_state.canceling}
  /// The function *onRefresh* **has not been executed**,
  /// and the indicator is hidding from its current value
  /// that is lower than *1.0* to *0.0*.
  /// {@endtemplate}
  canceling,

  /// {@template custom_refresh_indicator.indicator_state.armed}
  /// The user has dragged the pointer further than the distance
  /// declared by *containerExtentPercentageToArmed* or *offsetToArmed*
  /// (over the value of *1.0*). Releasing the pointer in this state will
  /// trigger the *onRefresh* function.
  /// {@endtemplate}
  armed,

  /// {@template custom_refresh_indicator.indicator_state.settling}
  /// The user has released the indicator in the armed state.
  /// The indicator settles on its target value *1.0*.
  /// {@endtemplate}
  settling,

  /// {@template custom_refresh_indicator.indicator_state.loading}
  /// The indicator is in its target value *1.0*.
  /// The *onRefresh* function is triggered.
  /// {@endtemplate}
  loading,

  /// {@template custom_refresh_indicator.indicator_state.complete}
  /// **OPTIONAL** - Provide `completeStateDuration` argument to enable it.
  /// The *onRefresh* callback has completed and the pointer remains
  /// at value *1.0* for the specified duration.
  /// {@endtemplate}
  complete,

  /// {@template custom_refresh_indicator.indicator_state.finalizing}
  /// The *onRefresh* function **has been executed**, and the indicator
  /// hides from the value *1.0* to *0.0*.
  /// {@endtemplate}
  finalizing,
}

extension IndicatorStateGetters on IndicatorState {
  /// {@macro custom_refresh_indicator.indicator_state.idle}
  bool get isIdle => this == IndicatorState.idle;

  /// {@macro custom_refresh_indicator.indicator_state.dragging}
  bool get isDragging => this == IndicatorState.dragging;

  /// {@macro custom_refresh_indicator.indicator_state.canceling}
  bool get isCanceling => this == IndicatorState.canceling;

  /// {@macro custom_refresh_indicator.indicator_state.armed}
  bool get isArmed => this == IndicatorState.armed;

  /// {@macro custom_refresh_indicator.indicator_state.settling}
  bool get isSettling => this == IndicatorState.settling;

  /// {@macro custom_refresh_indicator.indicator_state.loading}
  bool get isLoading => this == IndicatorState.loading;

  /// {@macro custom_refresh_indicator.indicator_state.complete}
  bool get isComplete => this == IndicatorState.complete;

  /// {@macro custom_refresh_indicator.indicator_state.finalizing}
  bool get isFinalizing => this == IndicatorState.finalizing;
}
