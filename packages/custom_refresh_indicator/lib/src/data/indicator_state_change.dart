import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';

/// Describes [IndicatorState] change.
@immutable
class IndicatorStateChange {
  final IndicatorState currentState;
  final IndicatorState newState;

  const IndicatorStateChange(this.currentState, this.newState);

  /// - When [from] and [to] are provided - returns `true` when state did change [from] to [to].
  /// - When only [from] is provided - returns `true` when state did change from [from].
  /// - When only [to] is provided - returns `true` when state did change to [to].
  /// - When [from] and [to] equals `null` - returns `true` for any state change.
  bool didChange({IndicatorState? from, IndicatorState? to}) {
    final stateChanged = currentState != newState;
    if (to == null && from != null) return currentState == from && stateChanged;
    if (to != null && from == null) return newState == to && stateChanged;
    if (to == null && from == null) return stateChanged;
    return currentState == from && newState == to;
  }

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is IndicatorStateChange &&
      other.currentState == currentState &&
      other.newState == newState;

  @override
  int get hashCode => Object.hash(currentState, newState);

  @override
  String toString() => "$runtimeType(${currentState.name} → ${newState.name})";
}
