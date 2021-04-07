part of custom_refresh_indicator;

class IndicatorStateHelper {
  /// Describes current [CustomRefreshIndicator] state
  IndicatorState get previousState => _previousState;
  IndicatorState _previousState = IndicatorState.idle;
  bool get wasArmed => _previousState == IndicatorState.armed;
  bool get wasDragging => _previousState == IndicatorState.dragging;
  bool get wasLoading => _previousState == IndicatorState.loading;
  bool get wasComplete => _previousState == IndicatorState.complete;
  bool get wasHiding => _previousState == IndicatorState.hiding;
  bool get wasIdle => _previousState == IndicatorState.idle;

  /// Describes current [CustomRefreshIndicator] state
  IndicatorState get state => _currentState;
  IndicatorState _currentState = IndicatorState.idle;
  bool get isArmed => _currentState == IndicatorState.armed;
  bool get isDragging => _currentState == IndicatorState.dragging;
  bool get isLoading => _currentState == IndicatorState.loading;
  bool get isComplete => _currentState == IndicatorState.complete;
  bool get isHiding => _currentState == IndicatorState.hiding;
  bool get isIdle => _currentState == IndicatorState.idle;

  /// Updates [state] and [previousState] data.
  void update(IndicatorState state) {
    this._previousState = this._currentState;
    this._currentState = state;
  }

  /// - When [from] and [to] are provided - returns `true` when state did change [from] to [to].
  /// - When only [from] is provided - returns `true` when state did change from [from].
  /// - When only [to] is provided - returns `true` when state did change to [to].
  /// - When [from] and [to] equals `null` - returns `true` for any state change.
  bool didStateChange({IndicatorState? from, IndicatorState? to}) {
    final stateChanged = _previousState != _currentState;
    if (to == null && from != null)
      return _previousState == from && stateChanged;
    if (to != null && from == null) return _currentState == to && stateChanged;
    if (to == null && from == null) return stateChanged;
    return _previousState == from && _currentState == to;
  }
}
