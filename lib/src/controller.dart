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
        _scrollingDirection = scrollingDirection ?? ScrollDirection.idle,
        _direction = direction ?? AxisDirection.down,
        _value = value ?? 0.0,
        _refreshEnabled = refreshEnabled ?? true,
        _shouldStopDrag = false;

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

  /// sets indicator state and notifies listeners
  @protected
  @visibleForTesting
  void setIndicatorState(IndicatorState newState) {
    _currentState = newState;

    notifyListeners();
  }

  /// Describes current [CustomRefreshIndicator] state
  IndicatorState get state => _currentState;
  bool get isArmed => _currentState == IndicatorState.armed;
  bool get isDragging => _currentState == IndicatorState.dragging;
  bool get isLoading => _currentState == IndicatorState.loading;
  bool get isComplete => _currentState == IndicatorState.complete;
  bool get isHiding => _currentState == IndicatorState.hiding;
  bool get isIdle => _currentState == IndicatorState.idle;

  bool _refreshEnabled;
  bool _shouldStopDrag;

  /// Whether custom refresh indicator can change [IndicatorState] from `idle` to `dragging`
  bool get isRefreshEnabled => _refreshEnabled;

  void stopDrag() {
    if (isDragging || isArmed) {
      _shouldStopDrag = true;
    } else {
      throw StateError(
        "stopDrag method can be used only during "
        "drag or armed indicator state.",
      );
    }
  }

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
}
