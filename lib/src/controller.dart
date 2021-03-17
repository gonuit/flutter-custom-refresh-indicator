part of custom_refresh_indicator;

/// Describes state of CustomRefreshIndicator
enum IndicatorState {
  /// #### [CustomRefreshIndicator] is idle (There is no action)
  ///
  /// (`CustomRefreshIndicatorData.value == 0`)
  idle,

  /// #### Whether user is dragging [CustomRefreshIndicator]
  /// ending the scroll **WILL NOT** result in `onRefresh` call
  ///
  /// (`CustomRefreshIndicatorData.value < 1`)
  dragging,

  /// #### [CustomRefreshIndicator] is armed
  /// ending the scroll **WILL** result in:
  /// - `CustomRefreshIndicator.onRefresh` call
  /// - change of status to `loading`
  /// - decreasing `CustomRefreshIndicatorData.value` to `1` in
  /// duration specified by `CustomRefreshIndicator.armedToLoadingDuration`)
  ///
  /// (`CustomRefreshIndicatorData.value >= 1`)
  armed,

  /// #### [CustomRefreshIndicator] is hiding indicator
  /// when `onRefresh` future is resolved or indicator was canceled
  /// (scroll ended when [IndicatorState] was equal to `dragging`
  /// so `value` was less than `1` or the user started scrolling through the list)
  ///
  /// (`CustomRefreshIndicatorData.value` decreases to `0`
  /// in duration specified by `CustomRefreshIndicator.draggingToIdleDuration`)
  hiding,

  /// #### [CustomRefreshIndicator] is awaiting on `onRefresh` call result
  /// When `onRefresh` will resolve [CustomRefreshIndicator] will change state
  /// from `loading` to `hiding` and decrease `CustomRefreshIndicatorData.value`
  /// from `1` to `0` in duration specified by `CustomRefreshIndicator.loadingToIdleDuration`
  ///
  /// (`CustomRefreshIndicatorData.value == 1`)
  loading,

  /// ### IMPORTANT
  /// This state is skipped by default.
  ///
  /// {@template custom_refresh_indicator.complete_state}
  /// If [CustomRefreshIndicator.completeStateDuration] argument is provided to CustomRefreshIndicator,
  /// state will changed from [loading] to [complete] for duration of [CustomRefreshIndicator.completeStateDuration].
  ///
  /// If [CustomRefreshIndicator.completeStateDuration] equals `null`, state
  /// will skip [complete] state and will immediately become [hidding].
  /// {@endtemplate}
  complete,
}

class IndicatorController extends ChangeNotifier {
  double _value;

  /// Current indicator value / progress
  double get value => _value;

  /// Creates [CustomRefreshIndicator] controller class
  factory IndicatorController({
    bool? refreshEnabled,
  }) =>
      IndicatorController._(refreshEnabled: refreshEnabled);

  IndicatorController._({
    double? value,
    AxisDirection? direction,
    ScrollDirection? scrollingDirection,
    IndicatorState? state,
    bool? refreshEnabled,
  })  : _currentState = state ?? IndicatorState.idle,
        _previousState = state ?? IndicatorState.idle,
        _scrollingDirection = scrollingDirection ?? ScrollDirection.idle,
        _direction = direction ?? AxisDirection.down,
        _value = value ?? 0.0,
        _refreshEnabled = refreshEnabled ?? true;

  @protected
  @visibleForTesting
  void setValue(double value) {
    _value = value;
    notifyListeners();
  }

  ScrollDirection _scrollingDirection;
  @protected
  @visibleForTesting
  void setScrollingDirection(ScrollDirection userScrollDirection) {
    _scrollingDirection = userScrollDirection;
    notifyListeners();
  }

  /// Direction in which user is scrolling
  ScrollDirection get scrollingDirection => _scrollingDirection;

  /// Scrolling is happening in the positive scroll offset direction.
  bool get isScrollingForward => scrollingDirection == ScrollDirection.forward;

  /// Scrolling is happening in the negative scroll offset direction.
  bool get isScrollingReverse => scrollingDirection == ScrollDirection.reverse;

  /// No scrolling is underway.
  bool get isScrollIdle => scrollingDirection == ScrollDirection.idle;

  AxisDirection _direction;

  /// Sets the direction in which list scrolls
  @protected
  @visibleForTesting
  void setAxisDirection(AxisDirection direction) {
    _direction = direction;
    notifyListeners();
  }

  /// The direction in which list scrolls
  ///
  /// For example:
  /// ```
  /// ListView.builder(
  ///   scrollDirection: Axis.horizontal,
  ///   reverse: true,
  ///   // ***
  /// ```
  /// will have the direction of `AxisDirection.left`
  AxisDirection get direction => _direction;

  /// Whether list scrolls horrizontally
  ///
  /// (direction equals `AxisDirection.left` or `AxisDirection.right`)
  bool get isHorizontalDirection =>
      direction == AxisDirection.left || direction == AxisDirection.right;

  /// Whether list scrolls vertically
  ///
  /// (direction equals `AxisDirection.up` or `AxisDirection.down`)
  bool get isVerticalDirection =>
      direction == AxisDirection.up || direction == AxisDirection.down;

  IndicatorState _currentState;
  IndicatorState _previousState;

  /// sets indicator state and notifies listeners
  @protected
  @visibleForTesting
  void setIndicatorState(IndicatorState newState) {
    _previousState = _currentState;
    _currentState = newState;

    notifyListeners(shiftState: false);
  }

  /// Describes previous [CustomRefreshIndicator] state
  IndicatorState get previousState => _previousState;
  bool get wasArmed => _previousState == IndicatorState.armed;
  bool get wasDragging => _previousState == IndicatorState.dragging;
  bool get wasLoading => _previousState == IndicatorState.loading;
  bool get wasComplete => _previousState == IndicatorState.complete;
  bool get wasHiding => _previousState == IndicatorState.hiding;
  bool get wasIdle => _previousState == IndicatorState.idle;

  /// Describes current [CustomRefreshIndicator] state
  IndicatorState get state => _currentState;
  bool get isArmed => _currentState == IndicatorState.armed;
  bool get isDragging => _currentState == IndicatorState.dragging;
  bool get isLoading => _currentState == IndicatorState.loading;
  bool get isComplete => _currentState == IndicatorState.complete;
  bool get isHiding => _currentState == IndicatorState.hiding;
  bool get isIdle => _currentState == IndicatorState.idle;

  bool _refreshEnabled;

  /// Whether custom refresh indicator can change [IndicatorState] from `idle` to `dragging`
  bool get isRefreshEnabled => _refreshEnabled;

  /// Disables list pull to refresh
  void disableRefresh() {
    _refreshEnabled = false;
    notifyListeners();
  }

  /// Enables list pull to refresh
  void enableRefresh() {
    _refreshEnabled = true;
    notifyListeners();
  }

  /// Returns `true` when state did change [from] to [to].
  bool didStateChange({IndicatorState? from, IndicatorState? to}) {
    final stateChanged = _previousState != _currentState;
    if (to == null && from != null)
      return _previousState == from && stateChanged;
    if (to != null && from == null) return _currentState == to && stateChanged;
    if (to == null && from == null) return stateChanged;
    return _previousState == from && _currentState == to;
  }

  /// Everytime [notifyListeners] method is called, [previousState] will be set to [state] value.
  @override
  void notifyListeners({bool shiftState = true}) {
    if (shiftState) _previousState = _currentState;
    super.notifyListeners();
  }
}
