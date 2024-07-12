import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Keeps overscroll data for the [ClampingWithOverscrollPhysics] scroll
/// physics.
///
/// Implemented by the [IndicatorController] class.
@experimental
mixin ClampingWithOverscrollPhysicsState {
  double _overscroll = 0;

  /// Returns true when overscroll is available.
  bool get _hasOverscroll => _overscroll > 0;

  void _addOverscroll(double delta) {
    _overscroll += delta;
    if (_overscroll < 0) {
      _overscroll = 0;
    }
  }

  void _removeOverscroll(double delta) {
    _overscroll -= delta;
    if (_overscroll < 0) {
      _overscroll = 0;
    }
  }

  @internal
  void clearPhysicsState() {
    _overscroll = 0;
  }
}

/// Creates scroll physics that prevent the scroll offset from exceeding the
/// bounds of the content while handling the overscroll.
class ClampingWithOverscrollPhysics extends ClampingScrollPhysics {
  final ClampingWithOverscrollPhysicsState _state;

  /// Creates scroll physics that prevent the scroll offset from exceeding the
  /// bounds of the content while handling the overscroll.
  const ClampingWithOverscrollPhysics({
    super.parent,
    required ClampingWithOverscrollPhysicsState state,
  }) : _state = state;

  @override
  ClampingWithOverscrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ClampingWithOverscrollPhysics(
      parent: buildParent(ancestor),
      state: _state,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              '$runtimeType.applyBoundaryConditions() was called redundantly.'),
          ErrorDescription(
            'The proposed new position, $value, is exactly equal to the current position of the '
            'given ${position.runtimeType}, ${position.pixels}.\n'
            'The applyBoundaryConditions method should only be called when the value is '
            'going to actually change the pixels, otherwise it is redundant.',
          ),
          DiagnosticsProperty<ScrollPhysics>(
              'The physics object in question was', this,
              style: DiagnosticsTreeStyle.errorProperty),
          DiagnosticsProperty<ScrollMetrics>(
              'The position object in question was', position,
              style: DiagnosticsTreeStyle.errorProperty),
        ]);
      }
      return true;
    }());

    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      // Underscroll.

      final delta = value - position.pixels;
      _state._addOverscroll(delta.abs());
      return delta;
    }
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      // Overscroll.
      final delta = value - position.pixels;
      _state._addOverscroll(delta);
      return delta;
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      // Hit top edge.
      final delta = value - position.minScrollExtent;
      _state._addOverscroll(delta);
      return delta;
    }
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) {
      // Hit bottom edge.
      final delta = value - position.maxScrollExtent;
      _state._addOverscroll(delta);
      return delta;
    }
    if (_state._hasOverscroll) {
      final delta = value - position.pixels;
      _state._removeOverscroll(delta.abs());

      return delta;
    } else {
      return 0;
    }
  }
}
