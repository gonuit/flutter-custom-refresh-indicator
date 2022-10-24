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
  }

  /// The direction in which the user scrolls.
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
  /// This is especially useful with [CustomRefreshIndicator.trigger]
  /// set to [IndicatorTrigger.bothEdges], as the gesture
  /// can then be triggered from both edges.
  ///
  /// It is null when the edge is still not determined by
  /// the [CustomRefreshIndicator] widget.
  IndicatorEdge? get edge => _edge;
  IndicatorEdge? _edge;

  /// Whether the [edge] was determined by the [CustomRefreshIndicator] widget.
  bool get hasEdge => edge != null;

  @protected
  @visibleForTesting
  void setIndicatorEdge(IndicatorEdge? edge) {
    _edge = edge;
  }

  /// The side of the scrollable on which the indicator should be displayed.
  IndicatorSide get side {
    final edge = this.edge;
    if (edge == null) return IndicatorSide.none;
    switch (direction) {
      case AxisDirection.up:
        return edge.isLeading ? IndicatorSide.bottom : IndicatorSide.top;
      case AxisDirection.right:
        return edge.isLeading ? IndicatorSide.left : IndicatorSide.right;
      case AxisDirection.down:
        return edge.isLeading ? IndicatorSide.top : IndicatorSide.bottom;
      case AxisDirection.left:
        return edge.isLeading ? IndicatorSide.right : IndicatorSide.left;
    }
  }

  /// The direction in which the list scrolls
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
  bool get isFinalizing => _currentState.isFinalizing;
  bool get isIdle => _currentState.isIdle;

  bool _shouldStopDrag;

  /// Should the dragging be stopped
  bool get shouldStopDrag => _shouldStopDrag;

  /// Whether custom refresh indicator can change [IndicatorState] from `idle` to `dragging`
  bool get isRefreshEnabled => _isRefreshEnabled;
  bool _isRefreshEnabled;

  void stopDrag() {
    if (state.isDragging || state.isArmed) {
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
