import 'dart:async';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Manipulates the refresh indicator state
class FakeRefresh {
  var _completer = Completer<void>();

  bool _called = false;
  bool get called => _called;

  Future<void> refresh() async {
    _called = true;
    return _completer.future;
  }

  Future<void> instantRefresh() async {
    _called = true;
    _completer.complete();
  }

  void complete() {
    _completer.complete();
  }

  void reset() {
    _called = false;
    _completer = Completer<void>();
  }
}

// The simplest indicator implementation without any visual feedback (only logic)
Widget buildWithoutIndicator(
  BuildContext context,
  Widget child,
  IndicatorController controller,
) =>
    child;

class DefaultList extends StatelessWidget {
  final int itemsCount;
  final bool reverse;
  final ScrollController? controller;
  final ScrollPhysics physics;

  const DefaultList({
    super.key,
    required this.itemsCount,
    this.reverse = false,
    this.controller,
    this.physics = const AlwaysScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      physics: physics,
      itemCount: itemsCount,
      reverse: reverse,
      itemBuilder: (context, index) => SizedBox(
        height: 200,
        child: Text((index + 1).toString()),
      ),
    );
  }
}

void main() {
  final fakeRefresh = FakeRefresh();

  tearDown(() {
    fakeRefresh.reset();
  });

  testWidgets('CustomRefreshIndicator - default behaviour',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();

    // Scroll animation
    await tester.pump(const Duration(milliseconds: 300));
    // Finish the indicator settle animation
    await tester.pump(const Duration(milliseconds: 300));
    // Finish the indicator hide animation
    await tester.pump(const Duration(milliseconds: 300));
    expect(fakeRefresh.called, isTrue);
  });

  testWidgets('CustomRefreshIndicator - nested, with notification predicate',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          notificationPredicate: (ScrollNotification notification) =>
              notification.depth == 1,
          onRefresh: fakeRefresh.instantRefresh,
          child: const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 600.0,
              child: DefaultList(itemsCount: 6),
            ),
          ),
        ),
      ),
    );

    // horizontal fling
    await tester.fling(find.text('1'), const Offset(300.0, 0.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isFalse);

    // vertical fling
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);
  });

  testWidgets('CustomRefreshIndicator - reverse', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(
            itemsCount: 1,
            reverse: true,
          ),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 600.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    // refres was not called as the scroll was triggered in the wrong direction
    expect(fakeRefresh.called, isFalse);

    await tester.fling(find.text('1'), const Offset(0.0, -600.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);
  });

  testWidgets('CustomRefreshIndicator - top - position',
      (WidgetTester tester) async {
    final controller = IndicatorController();

    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: controller,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.refresh,
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);

    // controller is in loading with the state with the value 1.0
    expect(controller.value, equals(1.0));
    expect(controller.state, equals(IndicatorState.loading));
    expect(controller.hasEdge, isTrue);
    expect(controller.edge, IndicatorEdge.leading);
    expect(controller.side, IndicatorSide.top);
    expect(controller.direction, AxisDirection.down);
    expect(controller.scrollingDirection, ScrollDirection.forward);
  });

  testWidgets('CustomRefreshIndicator - reverse - position',
      (WidgetTester tester) async {
    final controller = IndicatorController();

    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: controller,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.refresh,
          child: const DefaultList(itemsCount: 1, reverse: true),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, -600.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // controller is in loading with the state with the value 1.0
    expect(controller.value, equals(1.0));
    expect(controller.state, equals(IndicatorState.loading));
    expect(controller.hasEdge, isTrue);
    expect(controller.edge, IndicatorEdge.leading);
    expect(controller.side, IndicatorSide.bottom);
    expect(controller.direction, AxisDirection.up);
    expect(controller.scrollingDirection, ScrollDirection.forward);
  });

  testWidgets('CustomRefreshIndicator - no movement',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          onRefresh: fakeRefresh.instantRefresh,
          builder: buildWithoutIndicator,
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    // this fling is horizontal, not up or down
    await tester.fling(find.text('1'), const Offset(1.0, 0.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isFalse);
  });

  testWidgets('CustomRefreshIndicator - not enough',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          offsetToArmed: 200.0,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 199.9), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isFalse);
  });

  testWidgets('CustomRefreshIndicator - just enough',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          offsetToArmed: 200.0,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 200.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);
  });

  testWidgets('CustomRefreshIndicator - refresh (programmatically) - slow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.refresh,
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    bool completed = false;
    tester
        .state<CustomRefreshIndicatorState>(find.byType(CustomRefreshIndicator))
        .refresh()
        .then<void>((void value) {
      completed = true;
    });
    await tester.pump();
    expect(completed, isFalse);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);
    expect(completed, isFalse);
  });

  testWidgets('CustomRefreshIndicator - refresh (programmatically) - fast',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    bool completed = false;

    tester
        .state<CustomRefreshIndicatorState>(find.byType(CustomRefreshIndicator))
        .refresh()
        .then<void>((_) => completed = true);

    await tester.pump();
    expect(completed, isFalse);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);
    expect(completed, isTrue);
    completed = false;
    fakeRefresh.reset();
    tester
        .state<CustomRefreshIndicatorState>(find.byType(CustomRefreshIndicator))
        .refresh()
        .then<void>((void value) {
      completed = true;
    });
    await tester.pump();
    expect(completed, isFalse);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);
    expect(completed, isTrue);
  });

  testWidgets(
    'CustomRefreshIndicator - refresh (programmatically) - fast - twice',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomRefreshIndicator(
            builder: buildWithoutIndicator,
            onRefresh: fakeRefresh.instantRefresh,
            child: const DefaultList(itemsCount: 1),
          ),
        ),
      );

      bool completed = false;
      tester
          .state<CustomRefreshIndicatorState>(
              find.byType(CustomRefreshIndicator))
          .refresh()
          .then<void>((void value) {
        completed = true;
      });

      /// It is not possible to call the refresh method
      /// when refresh is alrady in progress
      expect(
        () => tester
            .state<CustomRefreshIndicatorState>(
                find.byType(CustomRefreshIndicator))
            .refresh(),
        throwsA(isA<StateError>()),
      );

      await tester.pump();
      expect(completed, isFalse);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(fakeRefresh.called, isTrue);
      expect(completed, isTrue);
    },
  );

  testWidgets(
      'CustomRefreshIndicator - hide (programmatically) - when not shown',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();

    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.refresh,
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    final state = tester.state<CustomRefreshIndicatorState>(
      find.byType(CustomRefreshIndicator),
    );

    expect(indicatorController.state.isIdle, isTrue);
    expect(() => state.hide(), throwsA(isA<StateError>()));
  });

  testWidgets(
    'CustomRefreshIndicator - refresh starts while scroll view moves back to 0.0 after overscroll',
    (WidgetTester tester) async {
      final scrollController = ScrollController();
      final indicatorController = IndicatorController();

      await tester.pumpWidget(
        MaterialApp(
          home: CustomRefreshIndicator(
            controller: indicatorController,
            builder: buildWithoutIndicator,
            durations: const RefreshIndicatorDurations(
              settleDuration: Duration(milliseconds: 150),
            ),
            onRefresh: fakeRefresh.instantRefresh,
            child: DefaultList(itemsCount: 6, controller: scrollController),
          ),
        ),
      );

      if (debugDefaultTargetPlatformOverride == TargetPlatform.macOS) {
        await tester.fling(find.text('1'), const Offset(0.0, 1500.0), 1000.0);
      } else {
        await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      }

      await tester.pump(const Duration(milliseconds: 100));
      final lastScrollOffset = scrollController.offset;
      expect(lastScrollOffset, lessThan(0.0));
      expect(fakeRefresh.called, isFalse);
      // start loading
      await tester.pump(const Duration(milliseconds: 300));
      // settle indicator
      await tester.pump(const Duration(milliseconds: 300));
      expect(scrollController.offset, greaterThan(lastScrollOffset));
      expect(fakeRefresh.called, isTrue);
      expect(scrollController.offset, lessThan(0.0));
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    }),
  );

  testWidgets('CustomRefreshIndicator does not force child to relayout',
      (WidgetTester tester) async {
    int layoutCount = 0;

    Widget layoutCallback(BuildContext context, BoxConstraints constraints) {
      layoutCount++;
      return const DefaultList(itemsCount: 6);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: LayoutBuilder(builder: layoutCallback),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();

    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));

    expect(layoutCount, 1);
  });

  testWidgets(
      'CustomRefreshIndicator - trigger mode - anywhere - should be shown when dragging from non-zero scroll position',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    final ScrollController scrollController = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          triggerMode: IndicatorTriggerMode.anywhere,
          onRefresh: fakeRefresh.refresh,
          child: DefaultList(itemsCount: 6, controller: scrollController),
        ),
      ),
    );

    scrollController.jumpTo(50.0);

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    expect(indicatorController.value, greaterThan(0.0));
    expect(indicatorController.value, lessThanOrEqualTo(1.0));
  });

  testWidgets(
      'CustomRefreshIndicator - reverse - trigger mode - anywhere - should be shown when dragging from non-zero scroll position',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    final ScrollController scrollController = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          triggerMode: IndicatorTriggerMode.anywhere,
          onRefresh: fakeRefresh.refresh,
          child: DefaultList(
            controller: scrollController,
            itemsCount: 6,
            reverse: true,
          ),
        ),
      ),
    );

    scrollController.jumpTo(50.0);

    await tester.fling(find.text('1'), const Offset(0.0, -600.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    expect(indicatorController.value, greaterThan(0.0));
    expect(indicatorController.value, lessThanOrEqualTo(1.0));
  });

  testWidgets(
      'CustomRefreshIndicator - trigger mode - anywhere - should not be shown when overscroll occurs due to inertia',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    final ScrollController scrollController = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          triggerMode: IndicatorTriggerMode.anywhere,
          onRefresh: fakeRefresh.refresh,
          child: DefaultList(itemsCount: 100, controller: scrollController),
        ),
      ),
    );

    scrollController.jumpTo(100.0);

    // Release finger before reach the edge.
    await tester.fling(find.text('1'), const Offset(0.0, 99.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    expect(indicatorController.state, equals(IndicatorState.idle));
    expect(indicatorController.value, equals(0.0));
    expect(fakeRefresh.called, isFalse);
  });

  testWidgets(
      'CustomRefreshIndicator - trigger mode - onEdge - should not be shown when dragging from non-zero scroll position',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.refresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, -10.0), 300.0);
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    expect(indicatorController.state, equals(IndicatorState.idle));
    expect(indicatorController.value, equals(0.0));
    expect(fakeRefresh.called, isFalse);
  });

  testWidgets(
      'CustomRefreshIndicator - reverse - trigger mode - onEdge - should be shown when dragging from non-zero scroll position',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          controller: indicatorController,
          onRefresh: fakeRefresh.refresh,
          child: const DefaultList(
            itemsCount: 6,
            reverse: true,
          ),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 10.0), 1000.0);
    await tester.fling(find.text('1'), const Offset(0.0, -300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    expect(indicatorController.state, equals(IndicatorState.idle));
    expect(indicatorController.value, equals(0.0));
  });

  testWidgets(
      'CustomRefreshIndicator - ScrollController.jumpTo - should not trigger the refresh indicator',
      (WidgetTester tester) async {
    final ScrollController scrollController =
        ScrollController(initialScrollOffset: 500.0);
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: DefaultList(itemsCount: 6, controller: scrollController),
        ),
      ),
    );

    scrollController.jumpTo(0.0);
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));

    expect(fakeRefresh.called, isFalse);
  });

  testWidgets('CustomRefreshIndicator - reverse - BouncingScrollPhysics',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(
            itemsCount: 4,
            reverse: true,
            physics: BouncingScrollPhysics(),
          ),
        ),
      ),
    );

    // Fling down to show refresh indicator
    await tester.fling(find.text('1'), const Offset(0.0, -250.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);
  });

  testWidgets('CustomRefreshIndicator - disallows indicator - glow - leading',
      (WidgetTester tester) async {
    bool glowAccepted = true;
    ScrollNotification? lastNotification;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(useMaterial3: false),
        home: CustomRefreshIndicator(
          leadingScrollIndicatorVisible: false,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: Builder(builder: (BuildContext context) {
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is OverscrollNotification &&
                    lastNotification is! OverscrollNotification) {
                  final OverscrollIndicatorNotification
                      confirmationNotification =
                      OverscrollIndicatorNotification(leading: true);
                  confirmationNotification.dispatch(context);
                  glowAccepted = confirmationNotification.accepted;
                }
                lastNotification = notification;
                return false;
              },
              child: const DefaultList(itemsCount: 6),
            );
          }),
        ),
      ),
    );

    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    expect(find.byType(GlowingOverscrollIndicator), findsOneWidget);

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();

    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);
    expect(glowAccepted, isFalse);
  });

  testWidgets('CustomRefreshIndicator - disallows indicator - glow - trailing',
      (WidgetTester tester) async {
    bool glowAccepted = true;
    ScrollNotification? lastNotification;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(useMaterial3: false),
        home: CustomRefreshIndicator(
          leadingScrollIndicatorVisible: true,
          trailingScrollIndicatorVisible: false,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: Builder(builder: (BuildContext context) {
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is OverscrollNotification &&
                    lastNotification is! OverscrollNotification) {
                  final OverscrollIndicatorNotification
                      confirmationNotification =
                      OverscrollIndicatorNotification(leading: false);
                  confirmationNotification.dispatch(context);
                  glowAccepted = confirmationNotification.accepted;
                }
                lastNotification = notification;
                return false;
              },
              child: const DefaultList(itemsCount: 6),
            );
          }),
        ),
      ),
    );

    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    expect(find.byType(GlowingOverscrollIndicator), findsOneWidget);

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();

    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);
    expect(glowAccepted, isFalse);
  });

  testWidgets('CustomRefreshIndicator - disallows indicator - stretch',
      (WidgetTester tester) async {
    bool stretchAccepted = true;
    ScrollNotification? lastNotification;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: CustomRefreshIndicator(
          leadingScrollIndicatorVisible: false,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: Builder(builder: (BuildContext context) {
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is OverscrollNotification &&
                    lastNotification is! OverscrollNotification) {
                  final OverscrollIndicatorNotification
                      confirmationNotification =
                      OverscrollIndicatorNotification(leading: true);
                  confirmationNotification.dispatch(context);
                  stretchAccepted = confirmationNotification.accepted;
                }
                lastNotification = notification;
                return false;
              },
              child: const DefaultList(itemsCount: 6),
            );
          }),
        ),
      ),
    );

    expect(find.byType(StretchingOverscrollIndicator), findsOneWidget);
    expect(find.byType(GlowingOverscrollIndicator), findsNothing);

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();

    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator settle animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    expect(fakeRefresh.called, isTrue);
    expect(stretchAccepted, isFalse);
  });

  testWidgets(
      'CustomRefreshIndicator - trigger - both edges  - should be shown when dragging from the start or end edge',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          trigger: IndicatorTrigger.bothEdges,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    // start edge
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));

    expect(indicatorController.value, greaterThan(0.0));
    expect(indicatorController.value, lessThanOrEqualTo(1.0));
    expect(indicatorController.edge, IndicatorEdge.leading);
    expect(fakeRefresh.called, isTrue);
    // finish the indicator
    await tester.pump(const Duration(seconds: 1));
    expect(indicatorController.edge, isNull);
    expect(indicatorController.value, equals(0.0));

    fakeRefresh.reset();

    // end edge

    // scroll to end
    await tester.fling(find.text('1'), const Offset(0.0, -1000.0), 1000.0);
    // trigger indicator
    await tester.fling(find.text('6'), const Offset(0.0, -300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));

    expect(indicatorController.value, greaterThan(0.0));
    expect(indicatorController.value, lessThanOrEqualTo(1.0));
    expect(indicatorController.edge, IndicatorEdge.trailing);
    expect(fakeRefresh.called, isTrue);

    // finish the indicator
    await tester.pump(const Duration(seconds: 1));
    expect(indicatorController.edge, isNull);
    expect(indicatorController.value, equals(0.0));
  });

  testWidgets(
      'CustomRefreshIndicator - trigger - end edge  - should be shown only when dragging from the end edge',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          trigger: IndicatorTrigger.trailingEdge,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    // start edge
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);

    expect(indicatorController.value, equals(0.0));
    expect(fakeRefresh.called, isFalse);

    // end edge
    await tester.fling(find.text('1'), const Offset(0.0, -300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));

    expect(indicatorController.value, greaterThan(0.0));
    expect(indicatorController.value, lessThanOrEqualTo(1.0));
    expect(indicatorController.edge, IndicatorEdge.trailing);
    expect(fakeRefresh.called, isTrue);

    // finish the indicator
    await tester.pump(const Duration(seconds: 1));
    expect(indicatorController.edge, isNull);
    expect(indicatorController.value, equals(0.0));
  });

  testWidgets(
      'CustomRefreshIndicator - trigger - start edge  - should be shown only when dragging from the end edge',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          trigger: IndicatorTrigger.leadingEdge,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    // end edge
    await tester.fling(find.text('1'), const Offset(0.0, -300.0), 1000.0);

    expect(indicatorController.value, equals(0.0));
    expect(fakeRefresh.called, isFalse);

    // start edge
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));

    expect(indicatorController.value, greaterThan(0.0));
    expect(indicatorController.value, lessThanOrEqualTo(1.0));
    expect(indicatorController.edge, IndicatorEdge.leading);
    expect(fakeRefresh.called, isTrue);
    // finish the indicator
    await tester.pump(const Duration(seconds: 1));
    expect(indicatorController.edge, isNull);
    expect(indicatorController.value, equals(0.0));
  });

  testWidgets('CustomRefreshIndicator - onStateChanged',
      (WidgetTester tester) async {
    final changes = <IndicatorStateChange>[];
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          onStateChanged: (change) => changes.add(change),
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    // start edge
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator
    await tester.pump(const Duration(seconds: 1));

    expect(changes, [
      const IndicatorStateChange(
        IndicatorState.idle,
        IndicatorState.dragging,
      ),
      const IndicatorStateChange(
        IndicatorState.dragging,
        IndicatorState.armed,
      ),
      const IndicatorStateChange(
        IndicatorState.armed,
        IndicatorState.settling,
      ),
      const IndicatorStateChange(
        IndicatorState.settling,
        IndicatorState.loading,
      ),
      const IndicatorStateChange(
        IndicatorState.loading,
        IndicatorState.finalizing,
      ),
      const IndicatorStateChange(
        IndicatorState.finalizing,
        IndicatorState.idle,
      )
    ]);

    expect(fakeRefresh.called, isTrue);
  });

  testWidgets('CustomRefreshIndicator - onStateChanged - with completed state',
      (WidgetTester tester) async {
    final changes = <IndicatorStateChange>[];
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          onStateChanged: (change) => changes.add(change),
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          durations: const RefreshIndicatorDurations(
            completeDuration: Duration(milliseconds: 300),
          ),
          child: const DefaultList(itemsCount: 1),
        ),
      ),
    );

    // start edge
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // wait for complete state
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator
    await tester.pump(const Duration(seconds: 1));

    expect(changes, [
      const IndicatorStateChange(
        IndicatorState.idle,
        IndicatorState.dragging,
      ),
      const IndicatorStateChange(
        IndicatorState.dragging,
        IndicatorState.armed,
      ),
      const IndicatorStateChange(
        IndicatorState.armed,
        IndicatorState.settling,
      ),
      const IndicatorStateChange(
        IndicatorState.settling,
        IndicatorState.loading,
      ),
      const IndicatorStateChange(
        IndicatorState.loading,
        IndicatorState.complete,
      ),
      const IndicatorStateChange(
        IndicatorState.complete,
        IndicatorState.finalizing,
      ),
      const IndicatorStateChange(
        IndicatorState.finalizing,
        IndicatorState.idle,
      )
    ]);

    expect(fakeRefresh.called, isTrue);
  });

  testWidgets(
      'CustomRefreshIndicator - BouncingPhysics - start from scroll update notification',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    final scrollController = ScrollController(initialScrollOffset: 0);
    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          trigger: IndicatorTrigger.bothEdges,
          onRefresh: fakeRefresh.instantRefresh,
          child: DefaultList(
            itemsCount: 1,
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
          ),
        ),
      ),
    );

    // start edge
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // wait for complete state
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator
    await tester.pump(const Duration(seconds: 1));

    expect(fakeRefresh.called, isTrue);
    fakeRefresh.reset();
    expect(fakeRefresh.called, isFalse);

    // end edge
    await tester.fling(find.text('1'), const Offset(0.0, -300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // wait for complete state
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator
    await tester.pump(const Duration(seconds: 1));

    expect(fakeRefresh.called, isTrue);
  });

  testWidgets(
      'CustomRefreshIndicator - autoRebuild - true - rebuilds the builder function with each change',
      (WidgetTester tester) async {
    int indicatorChangesCount = 0;
    int rebuildsCount = 0;

    final indicatorController = IndicatorController();
    indicatorController.addListener(() => indicatorChangesCount++);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: (
            BuildContext context,
            Widget child,
            IndicatorController controller,
          ) {
            rebuildsCount++;
            return child;
          },
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    // start edge
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // wait for complete state
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator
    await tester.pump(const Duration(seconds: 1));

    expect(rebuildsCount, greaterThan(10));
    expect(indicatorChangesCount, greaterThan(10));
    // A single change only marks the widget as ready for rebuilding, so the number of rebuilds will be less than updates.
    expect(rebuildsCount, lessThan(indicatorChangesCount));
  });

  testWidgets(
      'CustomRefreshIndicator - autoRebuild - false - invokes the builder function only for state changes',
      (WidgetTester tester) async {
    int indicatorChangesCount = 0;
    int rebuildsCount = 0;

    final states = <IndicatorState>[];

    final indicatorController = IndicatorController();
    indicatorController.addListener(() => indicatorChangesCount++);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomRefreshIndicator(
          autoRebuild: false,
          controller: indicatorController,
          onStateChanged: (change) => states.add(change.newState),
          builder: (
            BuildContext context,
            Widget child,
            IndicatorController controller,
          ) {
            rebuildsCount++;
            return child;
          },
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    // start edge
    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    // finish the scroll animation
    await tester.pump(const Duration(seconds: 1));
    // wait for complete state
    await tester.pump(const Duration(seconds: 1));
    // finish the indicator
    await tester.pump(const Duration(seconds: 1));

    expect(
      states,
      equals([
        IndicatorState.dragging,
        IndicatorState.armed,
        IndicatorState.settling,
        IndicatorState.loading,
        IndicatorState.finalizing,
        IndicatorState.idle
      ]),
    );

    /// Builder methos is called only on state changes
    expect(rebuildsCount, equals(states.length));
    expect(indicatorChangesCount, greaterThan(rebuildsCount));
  });
}
