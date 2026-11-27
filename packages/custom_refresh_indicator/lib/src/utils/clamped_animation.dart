import 'package:flutter/animation.dart';

/// An animation that clamps the value of another animation within a specified range.
///
/// This animation proxies the parent animation but enforces a minimum and a maximum
/// limit on its value. If the parent animation produces a value outside of this
/// range, it is clamped to the nearest boundary defined by [min] and [max].
///
/// The [min] value should be less than the [max] value.
///
/// Example usage:
/// ```dart
/// final ClampedAnimation clampedAnimation = ClampedAnimation(
///   parent: parent,
///   min: 0.0,
///   max: 1.0,
/// );
/// ```
/// Here `clampedAnimation.value` will always be between 0.0 and 1.0, inclusive.
class ClampedAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  /// Creates a clamped animation with an invariant range.
  ///
  /// The [parent] animation is the source of values for this animation.
  /// The [min] and [max] parameters specify the range within which the
  /// values of the parent animation should be clamped.
  /// The constructor asserts that [min] is less than [max].
  const ClampedAnimation({
    required this.parent,
    required this.min,
    required this.max,
  }) : assert(min < max, 'The min value must be less than the max value.');

  /// The animation that this clamped animation is based on.
  @override
  final Animation<double> parent;

  /// The minimum value of the clamped range.
  final double min;

  /// The maximum value of the clamped range.
  final double max;

  /// Gets the current value of the parent animation clamped to the range [min] to [max].
  ///
  /// This method overrides the getter for `value` from the parent class and applies
  /// the clamping logic to the current value of the [parent] animation.
  @override
  double get value => parent.value.clamp(min, max);

  @override
  String toString() => '$parent(min: $min, max: $max)';
}
