part of 'custom_refresh_indicator.dart';

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
        _isRefreshEnabled = refreshEnabled ?? true,
        _shouldStopDrag = false,
        _edge = IndicatorEdge.undetermined;

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
  }

  /// Whether the pull to refresh gesture is triggered from the start
  /// of the list or from the end.
  ///
  /// This is especially useful with [CustomRefreshIndicator.edge]
  /// set to [IndicatorTriggerEdge.both], as the gesture
  /// can then be triggered from both edges.
  IndicatorEdge get edge => _edge;
  IndicatorEdge _edge;

  @protected
  @visibleForTesting
  void setIndicatorEdge(IndicatorEdge edge) {
    _edge = edge;
  }

  IndicatorSide get side {
    if (edge.isUndetermined) return IndicatorSide.none;
    switch (direction) {
      case AxisDirection.up:
        return edge.isStart ? IndicatorSide.bottom : IndicatorSide.top;
      case AxisDirection.right:
        return edge.isStart ? IndicatorSide.right : IndicatorSide.left;
      case AxisDirection.down:
        return edge.isStart ? IndicatorSide.top : IndicatorSide.bottom;
      case AxisDirection.left:
        return edge.isStart ? IndicatorSide.left : IndicatorSide.right;
    }
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
  bool get isArmed => _currentState.isArmed;
  bool get isDragging => _currentState.isDragging;
  bool get isLoading => _currentState.isLoading;
  bool get isComplete => _currentState.isComplete;
  bool get isHiding => _currentState.isHiding;
  bool get isIdle => _currentState.isIdle;

  bool _shouldStopDrag;

  /// Whether custom refresh indicator can change [IndicatorState] from `idle` to `dragging`
  bool get isRefreshEnabled => _isRefreshEnabled;
  bool _isRefreshEnabled;

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
    _isRefreshEnabled = false;
    notifyListeners();
  }

  /// Enables list pull to refresh
  void enableRefresh() {
    _isRefreshEnabled = true;
    notifyListeners();
  }
}
