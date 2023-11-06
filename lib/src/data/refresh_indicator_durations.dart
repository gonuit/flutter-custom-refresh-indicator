/// Encapsulates the duration of various phases of the refresh indicator's animation.
///
/// The durations defined within are used to control how long each respective
/// phase lasts, allowing for customization of the refresh indicator's behavior.
class RefreshIndicatorDurations {
  /// Duration of hiding the indicator when dragging was stopped before
  /// the indicator was armed (the *onRefresh* callback was not called).
  ///
  /// The default is 300 milliseconds.
  final Duration cancelDuration;

  /// The time of settling the pointer on the target location after releasing
  /// the pointer in the armed state.
  ///
  /// During this process, the value of the indicator decreases from its current value,
  /// which can be greater than or equal to 1.0 but less or equal to 1.5,
  /// to a target value of `1.0`.
  /// During this process, the state is set to [IndicatorState.loading].
  ///
  /// The default is 150 milliseconds.
  final Duration settleDuration;

  /// Duration of hiding the pointer after the [onRefresh] function completes.
  ///
  /// During this time, the value of the controller decreases from `1.0` to `0.0`
  /// with a state set to [IndicatorState.finalizing].
  ///
  /// The default is 100 milliseconds.
  final Duration finalizeDuration;

  /// Duration for which the indicator remains at value of *1.0* and
  /// [IndicatorState.complete] state after the [onRefresh] function completes.
  final Duration? completeDuration;

  /// Constructs a `RefreshIndicatorDurations` with the specified durations.
  ///
  /// If a duration is not specified, it falls back to a default value:
  /// - `cancelDuration`: 300 milliseconds
  /// - `settleDuration`: 150 milliseconds
  /// - `finalizeDuration`: 100 milliseconds
  const RefreshIndicatorDurations({
    this.cancelDuration = const Duration(milliseconds: 300),
    this.settleDuration = const Duration(milliseconds: 150),
    this.finalizeDuration = const Duration(milliseconds: 100),
    this.completeDuration,
  });
}
