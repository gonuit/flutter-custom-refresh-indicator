import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _min = 0.0;
const _max = 1000.0;

ScrollMetrics metrics({required double pixels}) => FixedScrollMetrics(
      minScrollExtent: _min,
      maxScrollExtent: _max,
      pixels: pixels,
      viewportDimension: 600.0,
      axisDirection: AxisDirection.down,
      devicePixelRatio: 3.0,
    );

void main() {
  late IndicatorController controller;
  late ClampingWithOverscrollPhysics physics;

  setUp(() {
    controller = IndicatorController();
    physics = ClampingWithOverscrollPhysics(state: controller);
  });

  tearDown(() => controller.dispose());

  double drain({double step = 10.0, int attempts = 10}) {
    var total = 0.0;
    for (var i = 0; i < attempts; i++) {
      total += physics.applyBoundaryConditions(metrics(pixels: _min), step);
    }
    return total;
  }

  test('underscroll registers the overscroll', () {
    expect(
        physics.applyBoundaryConditions(metrics(pixels: _min), -20.0), -20.0);
    expect(drain(), 20.0);
  });

  test('overscroll registers the overscroll', () {
    expect(
      physics.applyBoundaryConditions(metrics(pixels: _max), 1020.0),
      20.0,
    );
    expect(drain(), 20.0);
  });

  test('hitting the leading edge registers the overscroll', () {
    expect(
        physics.applyBoundaryConditions(metrics(pixels: 10.0), -20.0), -20.0);
    expect(drain(), 20.0);
  });

  test('hitting the trailing edge registers the overscroll', () {
    expect(
      physics.applyBoundaryConditions(metrics(pixels: 990.0), 1020.0),
      20.0,
    );
    expect(drain(), 20.0);
  });

  test('leading and trailing edges register the same overscroll', () {
    physics.applyBoundaryConditions(metrics(pixels: 10.0), -20.0);
    final leading = drain();

    controller.clearPhysicsState();
    physics.applyBoundaryConditions(metrics(pixels: 990.0), 1020.0);
    final trailing = drain();

    expect(leading, trailing);
  });

  test('in bounds movement is not overscroll', () {
    expect(physics.applyBoundaryConditions(metrics(pixels: 500.0), 520.0), 0.0);
  });

  test('registered overscroll is drained before the list scrolls', () {
    physics.applyBoundaryConditions(metrics(pixels: _min), -20.0);

    expect(physics.applyBoundaryConditions(metrics(pixels: _min), 10.0), 10.0);
    expect(physics.applyBoundaryConditions(metrics(pixels: _min), 10.0), 10.0);
    expect(physics.applyBoundaryConditions(metrics(pixels: _min), 10.0), 0.0);
  });

  test('draining in the negative direction also reduces the overscroll', () {
    physics.applyBoundaryConditions(metrics(pixels: _min), -20.0);

    expect(
        physics.applyBoundaryConditions(metrics(pixels: 500.0), 490.0), -10.0);
    expect(
        physics.applyBoundaryConditions(metrics(pixels: 500.0), 490.0), -10.0);
    expect(physics.applyBoundaryConditions(metrics(pixels: 500.0), 490.0), 0.0);
  });

  test('draining more than was registered does not go negative', () {
    physics.applyBoundaryConditions(metrics(pixels: _min), -20.0);

    expect(physics.applyBoundaryConditions(metrics(pixels: _min), 50.0), 50.0);
    expect(physics.applyBoundaryConditions(metrics(pixels: _min), 10.0), 0.0);
  });

  test('clearPhysicsState discards the registered overscroll', () {
    physics.applyBoundaryConditions(metrics(pixels: _min), -20.0);
    controller.clearPhysicsState();

    expect(physics.applyBoundaryConditions(metrics(pixels: _min), 10.0), 0.0);
  });

  test('applyTo keeps the same state', () {
    final applied = physics.applyTo(const ClampingScrollPhysics());

    expect(applied, isA<ClampingWithOverscrollPhysics>());

    physics.applyBoundaryConditions(metrics(pixels: _min), -20.0);

    expect(applied.applyBoundaryConditions(metrics(pixels: _min), 20.0), 20.0);
  });

  test('applyBoundaryConditions asserts when called redundantly', () {
    const pixels = 500.0;
    final position = metrics(pixels: pixels);

    late FlutterError error;
    try {
      physics.applyBoundaryConditions(position, pixels);
    } on FlutterError catch (e) {
      error = e;
    }

    expect(error, isNotNull);
    expect(error.diagnostics.length, 4);
    expect(error.diagnostics[2], isA<DiagnosticsProperty<ScrollPhysics>>());
    expect(error.diagnostics[2].style, DiagnosticsTreeStyle.errorProperty);
    expect(error.diagnostics[2].value, physics);
    expect(error.diagnostics[3], isA<DiagnosticsProperty<ScrollMetrics>>());
    expect(error.diagnostics[3].style, DiagnosticsTreeStyle.errorProperty);
    expect(error.diagnostics[3].value, position);
    expect(
      error.toString(),
      contains('applyBoundaryConditions() was called redundantly'),
    );
  });
}
