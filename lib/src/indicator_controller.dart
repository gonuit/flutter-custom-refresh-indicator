part of 'custom_refresh_indicator.dart';

class IndicatorController extends Animation<double>
    with
        AnimationEagerListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin,
        ClampingWithOverscrollPhysicsState {
  double _value;

  /// Represents the **minimum** value that an indicator can have.
  static double get minValue => 0.0;

  /// Represents the **maximum** value that an indicator can have.
  static double get maxValue => 1.5;

  /// Current indicator value / progress
  @override
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

  @experimental
  DragUpdateDetails? get dragDetails => _dragDetails;
  DragUpdateDetails? _dragDetails;

  @protected
  @visibleForTesting
  void setIndicatorDragDetails(DragUpdateDetails? dragDetails) {
    _dragDetails = dragDetails;
  }

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

  /// Whether list scrolls horizontally
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

  /// {@macro custom_refresh_indicator.indicator_state.idle}
  bool get isIdle => _currentState.isIdle;

  /// {@macro custom_refresh_indicator.indicator_state.dragging}
  bool get isDragging => _currentState.isDragging;

  /// {@macro custom_refresh_indicator.indicator_state.canceling}
  bool get isCanceling => _currentState.isCanceling;

  /// {@macro custom_refresh_indicator.indicator_state.armed}
  bool get isArmed => _currentState.isArmed;

  /// {@macro custom_refresh_indicator.indicator_state.settling}
  bool get isSettling => _currentState.isSettling;

  /// {@macro custom_refresh_indicator.indicator_state.loading}
  bool get isLoading => _currentState.isLoading;

  /// {@macro custom_refresh_indicator.indicator_state.complete}
  bool get isComplete => _currentState.isComplete;

  /// {@macro custom_refresh_indicator.indicator_state.finalizing}
  bool get isFinalizing => _currentState.isFinalizing;

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

  /// Provides the status of the animation: [AnimationStatus.dismissed] when
  /// the indicator [state] is [IndicatorState.idle],
  /// and [AnimationStatus.forward] otherwise.
  @override
  AnimationStatus get status =>
      state.isIdle ? AnimationStatus.dismissed : AnimationStatus.forward;

  /// Returns [ClampedAnimation] that constrains the animation value of its parent
  /// within the given [min] and [max] range.
  ///
  /// - [min] represents the smallest value the animation can have. If the parent
  ///   animation's value falls below this, it will be clamped to this minimum value.
  /// - [max] represents the largest value the animation can have. If the parent
  ///   animation's value exceeds this, it will be clamped to this maximum value.
  Animation<double> clamp(double min, double max) => ClampedAnimation(
        parent: this,
        min: min,
        max: max,
      );

  /// Returns [TransformedAnimation], which transforms the animation value of its parent
  /// to the specified [min] and [max] range.
  ///
  /// - [min] represents the smallest value the animation can have.
  /// - [max] represents the largest value the animation can have.
  ///
  /// If instead of transforming the entire range of controller values, you want to use only a specific range, see the [clamp] method.
  Animation<double> transform(double min, double max) => TransformedAnimation(
        parent: this,
        fromMin: minValue,
        fromMax: maxValue,
        toMin: min,
        toMax: max,
      );

  /// Returns a new animation with the controller value transformed to the range from `0.0` to `1.0` inclusive.
  Animation<double> normalize() => transform(0.0, 1.0);
}
