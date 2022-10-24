/// Describes state of CustomRefreshIndicator widget.
enum IndicatorState {
  ///In this state, the indicator is not visible.
  ///No user action is performed. Value remains at *0.0*.
  idle,

  /// The user starts scrolling/dragging the pointer to refresh.
  /// Releasing the pointer in this state will not trigger
  /// the *onRefresh* function. The controller value changes
  /// from *0.0* to *1.0*.
  dragging,

  /// The function *onRefresh* **has not been executed**,
  /// and the indicator is hidding from its current value
  /// that is lower than *1.0* to *0.0*.
  canceling,

  /// The user has dragged the pointer further than the distance
  /// declared by *containerExtentPercentageToArmed* or *offsetToArmed*
  /// (over the value of *1.0*). Releasing the pointer in this state will
  /// trigger the *onRefresh* function.
  armed,

  /// The user has released the indicator in the armed state.
  /// The indicator settles on its target value *1.0* and
  /// the *onRefresh* function is called.
  loading,

  /// **OPTIONAL** - Provide `completeStateDuration` argument to enable it.
  /// The *onRefresh* callback has completed and the pointer remains
  /// at value *1.0* for the specified duration.
  complete,

  /// The *onRefresh* function **has been executed**, and the indicator
  /// hides from the value *1.0* to *0.0*.
  finalizing,
}

extension IndicatorStateGetters on IndicatorState {
  bool get isIdle => this == IndicatorState.idle;
  bool get isDragging => this == IndicatorState.dragging;
  bool get isArmed => this == IndicatorState.armed;
  bool get isFinalizing => this == IndicatorState.finalizing;
  bool get isCanceling => this == IndicatorState.canceling;
  bool get isLoading => this == IndicatorState.loading;
  bool get isComplete => this == IndicatorState.complete;
}
