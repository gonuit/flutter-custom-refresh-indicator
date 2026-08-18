import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/test_utils.dart';

const _materialPlatforms = <TargetPlatform>[
  TargetPlatform.android,
  TargetPlatform.fuchsia,
  TargetPlatform.linux,
  TargetPlatform.windows,
];

const _cupertinoPlatforms = <TargetPlatform>[
  TargetPlatform.iOS,
  TargetPlatform.macOS,
];

void main() {
  final fakeRefresh = FakeRefresh();

  tearDown(fakeRefresh.reset);

  RefreshProgressIndicator getIndicator(WidgetTester tester) =>
      tester.widget<RefreshProgressIndicator>(
        find.byType(RefreshProgressIndicator),
      );

  Color? getValueColor(WidgetTester tester) =>
      getIndicator(tester).valueColor?.value;

  Material getCircleMaterial(WidgetTester tester) => tester
      .widgetList<Material>(find.byType(Material))
      .firstWhere((material) => material.type == MaterialType.circle);

  Future<void> flingToLoading(WidgetTester tester) async {
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester
        .pump(const Duration(seconds: 1)); // finish the scroll animation
    await tester.pump(
        const Duration(seconds: 1)); // finish the indicator settle animation
  }

  Future<void> finishRefresh(WidgetTester tester) async {
    fakeRefresh.complete();
    await tester.pump();
    await tester
        .pump(const Duration(seconds: 1)); // finish the finalize animation
    await tester.pump(
        const Duration(seconds: 1)); // finish the indicator hide animation
  }

  Widget buildIndicator({
    required Widget child,
    IndicatorController? controller,
    Color? color,
    Color? backgroundColor,
    MaterialIndicatorBuilder? indicatorBuilder,
    ThemeData? theme,
  }) =>
      MaterialApp(
        theme: theme,
        home: CustomMaterialIndicator(
          controller: controller,
          onRefresh: fakeRefresh.refresh,
          color: color,
          backgroundColor: backgroundColor,
          indicatorBuilder: indicatorBuilder,
          child: child,
        ),
      );

  testWidgets('CustomMaterialIndicator', (WidgetTester tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    expect(find.byType(RefreshProgressIndicator), findsNothing);

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();

    expect(
      tester.getSemantics(find.byType(RefreshProgressIndicator)),
      matchesSemantics(label: 'Refresh'),
    );

    await tester
        .pump(const Duration(seconds: 1)); // finish the scroll animation
    await tester.pump(
        const Duration(seconds: 1)); // finish the indicator settle animation
    await tester.pump(
        const Duration(seconds: 1)); // finish the indicator hide animation

    expect(fakeRefresh.called, isTrue);
    expect(find.byType(RefreshProgressIndicator), findsNothing);
    handle.dispose();
  });

  testWidgets('CustomMaterialIndicator - value is indeterminate while loading',
      (WidgetTester tester) async {
    final controller = IndicatorController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildIndicator(
        controller: controller,
        child: const DefaultList(itemsCount: 6),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.text('1')));
    await gesture.moveBy(const Offset(0.0, 40.0));
    await tester.pump();

    expect(controller.state, IndicatorState.dragging);
    expect(getIndicator(tester).value, isNotNull);

    await gesture.moveBy(const Offset(0.0, 260.0));
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.state, IndicatorState.loading);
    expect(getIndicator(tester).value, isNull);

    fakeRefresh.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(controller.state, IndicatorState.finalizing);
    expect(getIndicator(tester).value, isNull);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('CustomMaterialIndicator - responds to strokeWidth',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.refresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await flingToLoading(tester);

    expect(
      getIndicator(tester).strokeWidth,
      RefreshProgressIndicator.defaultStrokeWidth,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.refresh,
          strokeWidth: 8.0,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    expect(getIndicator(tester).strokeWidth, 8.0);
    await finishRefresh(tester);
  });

  testWidgets('CustomMaterialIndicator - responds to backgroundColor',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildIndicator(
        backgroundColor: Colors.amber,
        child: const DefaultList(itemsCount: 6),
      ),
    );

    await flingToLoading(tester);

    expect(getIndicator(tester).backgroundColor, Colors.amber);
    await finishRefresh(tester);
  });

  testWidgets('CustomMaterialIndicator - responds to semantics labels',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.refresh,
          semanticsLabel: 'Reloading',
          semanticsValue: '50',
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await flingToLoading(tester);

    expect(getIndicator(tester).semanticsLabel, 'Reloading');
    expect(getIndicator(tester).semanticsValue, '50');
    await finishRefresh(tester);
  });

  testWidgets('CustomMaterialIndicator - color defaults to ColorScheme.primary',
      (WidgetTester tester) async {
    const primaryColor = Color(0xff4caf50);

    await tester.pumpWidget(
      buildIndicator(
        theme: ThemeData.from(
          colorScheme:
              const ColorScheme.light().copyWith(primary: primaryColor),
        ),
        child: const DefaultList(itemsCount: 6),
      ),
    );

    await flingToLoading(tester);

    expect(getValueColor(tester), primaryColor);
    await finishRefresh(tester);
  });

  testWidgets('CustomMaterialIndicator - color alpha ramps up with the drag',
      (WidgetTester tester) async {
    const color = Color(0xff2196f3);
    final controller = IndicatorController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildIndicator(
        controller: controller,
        color: color,
        child: const DefaultList(itemsCount: 6),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.text('1')));
    await gesture.moveBy(const Offset(0.0, 40.0));
    await tester.pump();

    final partial = getValueColor(tester)!;
    expect(partial, isNot(color));
    expect(partial, isNot(color.withAlpha(0)));
    expect(partial.withAlpha(0xff), color);

    await gesture.moveBy(const Offset(0.0, 110.0));
    await tester.pump();

    expect(getValueColor(tester), isNot(partial));

    await gesture.moveBy(const Offset(0.0, 150.0));
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.isLoading, isTrue);
    expect(getValueColor(tester), color);
    await finishRefresh(tester);
  });

  testWidgets(
      'CustomMaterialIndicator - fully transparent color stays transparent',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildIndicator(
        color: Colors.transparent,
        child: const DefaultList(itemsCount: 6),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.text('1')));

    for (final step in <double>[40.0, 60.0, 120.0, 240.0]) {
      await gesture.moveBy(Offset(0.0, step));
      await tester.pump();

      expect(
        getIndicator(tester).valueColor,
        isA<AlwaysStoppedAnimation<Color>>(),
      );
      expect(getValueColor(tester), Colors.transparent);
    }

    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await finishRefresh(tester);
  });

  testWidgets('CustomMaterialIndicator - color can be updated at runtime',
      (WidgetTester tester) async {
    var color = const Color(0xff4caf50);
    late StateSetter setState;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            setState = stateSetter;
            return CustomMaterialIndicator(
              onRefresh: fakeRefresh.refresh,
              color: color,
              child: const DefaultList(itemsCount: 6),
            );
          },
        ),
      ),
    );

    await flingToLoading(tester);

    expect(getValueColor(tester), color);

    setState(() {
      color = const Color(0xfff44336);
    });
    await tester.pump();

    expect(getValueColor(tester), color);
    await finishRefresh(tester);
  });

  testWidgets(
      'CustomMaterialIndicator - backgroundColor can be updated at runtime',
      (WidgetTester tester) async {
    var backgroundColor = Colors.amber;
    late StateSetter setState;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            setState = stateSetter;
            return CustomMaterialIndicator(
              onRefresh: fakeRefresh.refresh,
              backgroundColor: backgroundColor,
              child: const DefaultList(itemsCount: 6),
            );
          },
        ),
      ),
    );

    await flingToLoading(tester);

    expect(getIndicator(tester).backgroundColor, Colors.amber);

    setState(() {
      backgroundColor = Colors.teal;
    });
    await tester.pump();

    expect(getIndicator(tester).backgroundColor, Colors.teal);
    await finishRefresh(tester);
  });

  testWidgets('CustomMaterialIndicator.adaptive', (WidgetTester tester) async {
    Widget buildFrame(TargetPlatform platform) => MaterialApp(
          theme: ThemeData(platform: platform),
          home: CustomMaterialIndicator.adaptive(
            onRefresh: fakeRefresh.instantRefresh,
            child: const DefaultList(itemsCount: 6),
          ),
        );

    for (final platform in _cupertinoPlatforms) {
      await tester.pumpWidget(buildFrame(platform));
      await tester.pumpAndSettle(); // Finish the theme change animation.
      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(RefreshProgressIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      fakeRefresh.reset();
    }

    for (final platform in _materialPlatforms) {
      await tester.pumpWidget(buildFrame(platform));
      await tester.pumpAndSettle(); // Finish the theme change animation.
      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await tester.pump();

      expect(find.byType(RefreshProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      fakeRefresh.reset();
    }
  });

  testWidgets('CustomMaterialIndicator.adaptive - forwards color on iOS',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: CustomMaterialIndicator.adaptive(
          onRefresh: fakeRefresh.refresh,
          color: Colors.purple,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await flingToLoading(tester);

    expect(
      tester
          .widget<CupertinoActivityIndicator>(
            find.byType(CupertinoActivityIndicator),
          )
          .color,
      Colors.purple,
    );
    await finishRefresh(tester);
  });

  testWidgets('CustomMaterialIndicator - indicatorBuilder replaces the default',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildIndicator(
        indicatorBuilder: (context, controller) =>
            const SizedBox.expand(key: ValueKey('custom')),
        child: const DefaultList(itemsCount: 6),
      ),
    );

    await flingToLoading(tester);

    expect(find.byKey(const ValueKey('custom')), findsOneWidget);
    expect(find.byType(RefreshProgressIndicator), findsNothing);
    await finishRefresh(tester);
  });

  testWidgets(
      'CustomMaterialIndicator - indicatorBuilder is wrapped in a material container',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.refresh,
          backgroundColor: Colors.amber,
          elevation: 8.0,
          clipBehavior: Clip.antiAlias,
          indicatorBuilder: (context, controller) =>
              const SizedBox.expand(key: ValueKey('custom')),
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await flingToLoading(tester);

    final material = getCircleMaterial(tester);
    expect(material.color, Colors.amber);
    expect(material.elevation, 8.0);
    expect(material.clipBehavior, Clip.antiAlias);
    await finishRefresh(tester);
  });

  testWidgets(
      'CustomMaterialIndicator - useMaterialContainer false drops the container',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.refresh,
          useMaterialContainer: false,
          indicatorBuilder: (context, controller) =>
              const SizedBox.expand(key: ValueKey('custom')),
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await flingToLoading(tester);

    expect(find.byKey(const ValueKey('custom')), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Material && widget.type == MaterialType.circle,
      ),
      findsNothing,
    );
    await finishRefresh(tester);
  });

  testWidgets('CustomMaterialIndicator - responds to indicatorSize',
      (WidgetTester tester) async {
    const size = Size(80.0, 60.0);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.refresh,
          indicatorSize: size,
          indicatorBuilder: (context, controller) =>
              const SizedBox.expand(key: ValueKey('custom')),
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await flingToLoading(tester);

    expect(tester.getSize(find.byKey(const ValueKey('custom'))), size);
    await finishRefresh(tester);
  });

  testWidgets(
      'CustomMaterialIndicator - indicatorBuilder asserts unused arguments',
      (WidgetTester tester) async {
    Widget builder(BuildContext context, IndicatorController controller) =>
        const SizedBox.shrink();

    expect(
      () => CustomMaterialIndicator(
        onRefresh: fakeRefresh.refresh,
        indicatorBuilder: builder,
        color: Colors.red,
        child: const SizedBox.shrink(),
      ),
      throwsAssertionError,
    );
    expect(
      () => CustomMaterialIndicator(
        onRefresh: fakeRefresh.refresh,
        indicatorBuilder: builder,
        semanticsLabel: 'label',
        child: const SizedBox.shrink(),
      ),
      throwsAssertionError,
    );
    expect(
      () => CustomMaterialIndicator(
        onRefresh: fakeRefresh.refresh,
        indicatorBuilder: builder,
        semanticsValue: 'value',
        child: const SizedBox.shrink(),
      ),
      throwsAssertionError,
    );
    expect(
      () => CustomMaterialIndicator(
        onRefresh: fakeRefresh.refresh,
        indicatorBuilder: builder,
        strokeWidth: 4.0,
        child: const SizedBox.shrink(),
      ),
      throwsAssertionError,
    );
  });

  testWidgets('CustomMaterialIndicator - responds to displacement',
      (WidgetTester tester) async {
    Widget buildFrame(double displacement) => MaterialApp(
          home: CustomMaterialIndicator(
            onRefresh: fakeRefresh.refresh,
            displacement: displacement,
            child: const DefaultList(itemsCount: 6),
          ),
        );

    await tester.pumpWidget(buildFrame(40.0));
    await flingToLoading(tester);
    final defaultOffset =
        tester.getTopLeft(find.byType(RefreshProgressIndicator)).dy;
    await finishRefresh(tester);
    fakeRefresh.reset();

    await tester.pumpWidget(buildFrame(120.0));
    await flingToLoading(tester);
    final movedOffset =
        tester.getTopLeft(find.byType(RefreshProgressIndicator)).dy;
    await finishRefresh(tester);

    expect(movedOffset, greaterThan(defaultOffset));
  });

  testWidgets('CustomMaterialIndicator - responds to edgeOffset',
      (WidgetTester tester) async {
    Widget buildFrame(double edgeOffset) => MaterialApp(
          home: CustomMaterialIndicator(
            onRefresh: fakeRefresh.refresh,
            edgeOffset: edgeOffset,
            child: const DefaultList(itemsCount: 6),
          ),
        );

    await tester.pumpWidget(buildFrame(0.0));
    await flingToLoading(tester);
    final defaultOffset =
        tester.getTopLeft(find.byType(RefreshProgressIndicator)).dy;
    await finishRefresh(tester);
    fakeRefresh.reset();

    await tester.pumpWidget(buildFrame(100.0));
    await flingToLoading(tester);
    final movedOffset =
        tester.getTopLeft(find.byType(RefreshProgressIndicator)).dy;
    await finishRefresh(tester);

    expect(movedOffset - defaultOffset, 100.0);
  });

  testWidgets('CustomMaterialIndicator - uses the scrollableBuilder',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.instantRefresh,
          scrollableBuilder: (context, child, controller) => ColoredBox(
            key: const ValueKey('scrollable'),
            color: const Color(0xff000000),
            child: child,
          ),
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('scrollable')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('scrollable')),
        matching: find.byType(ListView),
      ),
      findsOneWidget,
    );
  });

  testWidgets('CustomMaterialIndicator - autoRebuild false limits rebuilds',
      (WidgetTester tester) async {
    Future<int> countBuilds({required bool autoRebuild}) async {
      var builds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: CustomMaterialIndicator(
            onRefresh: fakeRefresh.refresh,
            autoRebuild: autoRebuild,
            indicatorBuilder: (context, controller) {
              builds++;
              return const SizedBox.expand();
            },
            child: const DefaultList(itemsCount: 6),
          ),
        ),
      );

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('1')));
      for (var i = 0; i < 8; i++) {
        await gesture.moveBy(const Offset(0.0, 20.0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await finishRefresh(tester);
      fakeRefresh.reset();

      return builds;
    }

    final withAutoRebuild = await countBuilds(autoRebuild: true);
    final withoutAutoRebuild = await countBuilds(autoRebuild: false);

    expect(withoutAutoRebuild, lessThan(withAutoRebuild));
  });

  testWidgets('CustomMaterialIndicator - forwards the notificationPredicate',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.instantRefresh,
          notificationPredicate: (ScrollNotification notification) => false,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(fakeRefresh.called, isFalse);
    expect(find.byType(RefreshProgressIndicator), findsNothing);
  });

  testWidgets('CustomMaterialIndicator - forwards the trigger',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.instantRefresh,
          trigger: IndicatorTrigger.trailingEdge,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(fakeRefresh.called, isFalse);
  });

  testWidgets('CustomMaterialIndicator - forwards onStateChanged',
      (WidgetTester tester) async {
    final states = <IndicatorState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: CustomMaterialIndicator(
          onRefresh: fakeRefresh.instantRefresh,
          onStateChanged: (change) => states.add(change.newState),
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(
      states,
      containsAllInOrder(<IndicatorState>[
        IndicatorState.dragging,
        IndicatorState.armed,
        IndicatorState.loading,
        IndicatorState.finalizing,
        IndicatorState.idle,
      ]),
    );
  });

  testWidgets(
      'CustomMaterialIndicator - does not dispose an externally provided controller',
      (WidgetTester tester) async {
    final controller = IndicatorController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildIndicator(
        controller: controller,
        child: const DefaultList(itemsCount: 6),
      ),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    expect(() => controller.addListener(() {}), returnsNormally);
  });

  testWidgets('CustomMaterialIndicator - disposes the internal controller',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildIndicator(child: const DefaultList(itemsCount: 6)),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('CustomMaterialIndicator - swaps between controllers',
      (WidgetTester tester) async {
    final controller = IndicatorController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildIndicator(child: const DefaultList(itemsCount: 6)),
    );
    await tester.pumpWidget(
      buildIndicator(
        controller: controller,
        child: const DefaultList(itemsCount: 6),
      ),
    );
    await tester.pumpWidget(
      buildIndicator(child: const DefaultList(itemsCount: 6)),
    );

    expect(tester.takeException(), isNull);

    await flingToLoading(tester);

    expect(fakeRefresh.called, isTrue);
    await finishRefresh(tester);
  });

  testWidgets('CustomMaterialIndicator - does not crash at zero area',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox.shrink(
            child: CustomMaterialIndicator(
              onRefresh: fakeRefresh.instantRefresh,
              child: const DefaultList(itemsCount: 6),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(CustomMaterialIndicator)), Size.zero);

    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(Center)));
    await gesture.moveBy(const Offset(0.0, 20.0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
