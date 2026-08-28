import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/test_utils.dart';

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

  Future<void> pumpList(
    WidgetTester tester, {
    required IndicatorController indicatorController,
    required ScrollController scrollController,
    required AsyncCallback onRefresh,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          onRefresh: onRefresh,
          child: DefaultList(
            itemsCount: 20,
            controller: scrollController,
            physics: AlwaysScrollableScrollPhysics(
              parent: ClampingWithOverscrollPhysics(state: indicatorController),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> dragBy(WidgetTester tester, double offset) async {
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(ListView)));
    await gesture.moveBy(Offset(0.0, offset));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    // finish the scroll and indicator animations
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('the list still scrolls after overscrolling while idle',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    final scrollController = ScrollController();
    final fakeRefresh = FakeRefresh();
    addTearDown(indicatorController.dispose);
    addTearDown(scrollController.dispose);

    await pumpList(
      tester,
      indicatorController: indicatorController,
      scrollController: scrollController,
      onRefresh: fakeRefresh.instantRefresh,
    );

    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pump();

    await dragBy(tester, -80.0);

    expect(indicatorController.state, IndicatorState.idle);

    final offsetBefore = scrollController.offset;
    await dragBy(tester, 100.0);

    expect(scrollController.offset, lessThan(offsetBefore - 50.0));
  });

  testWidgets('the list scrolls back within the overscrolling gesture',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    final scrollController = ScrollController();
    final fakeRefresh = FakeRefresh();
    addTearDown(indicatorController.dispose);
    addTearDown(scrollController.dispose);

    await pumpList(
      tester,
      indicatorController: indicatorController,
      scrollController: scrollController,
      onRefresh: fakeRefresh.instantRefresh,
    );

    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pump();

    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(ListView)));
    await gesture.moveBy(const Offset(0.0, -80.0));
    await tester.pump();

    final offsetBefore = scrollController.offset;
    await gesture.moveBy(const Offset(0.0, 40.0));
    await tester.pump();

    expect(scrollController.offset, lessThan(offsetBefore));

    await gesture.up();
    await tester.pump();
    // finish the scroll and indicator animations
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('the list scrolls within a gesture while loading',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    final scrollController = ScrollController();
    final fakeRefresh = FakeRefresh();
    addTearDown(indicatorController.dispose);
    addTearDown(scrollController.dispose);

    await pumpList(
      tester,
      indicatorController: indicatorController,
      scrollController: scrollController,
      onRefresh: fakeRefresh.refresh,
    );

    await dragBy(tester, 200.0);

    expect(indicatorController.state, IndicatorState.loading);

    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(ListView)));
    await gesture.moveBy(const Offset(0.0, 60.0));
    await tester.pump();

    final offsetBefore = scrollController.offset;
    await gesture.moveBy(const Offset(0.0, -40.0));
    await tester.pump();

    expect(scrollController.offset, greaterThan(offsetBefore));

    await gesture.up();
    fakeRefresh.complete();
    await tester.pump();
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('the list still scrolls after overscrolling while loading',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    final scrollController = ScrollController();
    final fakeRefresh = FakeRefresh();
    addTearDown(indicatorController.dispose);
    addTearDown(scrollController.dispose);

    await pumpList(
      tester,
      indicatorController: indicatorController,
      scrollController: scrollController,
      onRefresh: fakeRefresh.refresh,
    );

    await dragBy(tester, 200.0);

    expect(indicatorController.state, IndicatorState.loading);

    await dragBy(tester, 80.0);

    final offsetBefore = scrollController.offset;
    await dragBy(tester, -100.0);

    expect(indicatorController.state, IndicatorState.loading);
    expect(scrollController.offset, greaterThan(offsetBefore + 50.0));

    fakeRefresh.complete();
    await tester.pump();
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });
}
