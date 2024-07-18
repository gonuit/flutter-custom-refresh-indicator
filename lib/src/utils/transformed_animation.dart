import 'package:flutter/animation.dart';

/// An animation that transforms the value of another animation from a certain range to another.
///
/// This animation proxies the parent animation, but enforces the minimum and maximum values
/// in the [toMin] and [toMax] range.
///
/// *From* values should be less than *max* values.
///
/// Example usage:
/// ```dart
/// final TransformedAnimation animation = TransformedAnimation(
///   parent: parent,
///   fromMin: 0.0,
///   fromMax: 1.0,
///   toMin: 0.0,
///   toMax: 10.0,
/// );
/// ```
/// Here `animation.value` will always be between 0.0 and 10.0, inclusive.
class TransformedAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  /// Creates a transformed animation with an invariant range.
  ///
  /// The [parent] animation is the source of values for this animation.
  /// The [fromMin] and [fromMax] parameters specify the range of the parent animation value that should be transformed.
  /// The [toMin] and [toMax] parameters specify the range to which the animation value should be transformed.
  ///
  /// The constructor asserts that [fromMin] is less than [fromMax] and [toMin] is less than [toMax].
  const TransformedAnimation({
    required this.parent,
    required this.fromMin,
    required this.fromMax,
    required this.toMin,
    required this.toMax,
  })  : assert(fromMin < fromMax,
            'The fromMin value must be less than the fromMax value.'),
        assert(toMin < toMax,
            'The toMin value must be less than the toMax value.');

  /// The animation that this clamped animation is based on.
  @override
  final Animation<double> parent;

  /// The minimum value of the current range.
  final double fromMin;

  /// The maximum value of the current range.
  final double fromMax;

  /// The minimum value of the transformed range.
  final double toMin;

  /// The maximum value of the transformed range.
  final double toMax;

  /// Gets the current value of the parent animation transformed from the range [fromMin] -> [toMax] to [toMin] -> [toMax].
  @override
  double get value {
    return (parent.value - fromMin) / (fromMax - fromMin) * (toMax - toMin) +
        toMin;
  }

  @override
  String toString() => 'TransformedAnimation(min: $toMin, max: $toMax)';
}
