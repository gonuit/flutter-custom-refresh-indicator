import 'dart:async';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  final fakeRefresh = FakeRefresh();

  tearDown(() {
    fakeRefresh.reset();
  });

  testWidgets('CustomRefreshIndicator - default behaviour',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
        TestApp(
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
      TestApp(
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
        TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
        scrollBehavior: const ScrollBehavior(),
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
      TestApp(
        scrollBehavior: const ScrollBehavior(),
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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
      TestApp(
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

  testWidgets('CustomRefreshIndicator - show - throws when not idle',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    addTearDown(indicatorController.dispose);

    await tester.pumpWidget(
      TestApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.refresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    final state = tester.state<CustomRefreshIndicatorState>(
        find.byType(CustomRefreshIndicator));

    state.show();
    // finish the show animation
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(indicatorController.state, IndicatorState.loading);
    expect(
      () => state.show(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('Controller must be in the idle state'),
            contains(IndicatorState.loading.name),
          ),
        ),
      ),
    );

    state.hide();
    await tester.pump();
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
      'CustomRefreshIndicator - disallows indicator - opposite edge while dragged',
      (WidgetTester tester) async {
    bool glowAccepted = true;
    ScrollNotification? lastNotification;

    await tester.pumpWidget(
      TestApp(
        scrollBehavior: const ScrollBehavior(),
        home: CustomRefreshIndicator(
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

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(fakeRefresh.called, isTrue);
    expect(glowAccepted, isFalse);
  });

  testWidgets(
      'CustomRefreshIndicator - allows indicator - dragged edge stays visible',
      (WidgetTester tester) async {
    bool glowAccepted = false;
    ScrollNotification? lastNotification;

    await tester.pumpWidget(
      TestApp(
        scrollBehavior: const ScrollBehavior(),
        home: CustomRefreshIndicator(
          leadingScrollIndicatorVisible: true,
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

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(fakeRefresh.called, isTrue);
    expect(glowAccepted, isTrue);
  });

  testWidgets('CustomRefreshIndicator - stops driving a detached controller',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    addTearDown(indicatorController.dispose);

    Widget build({IndicatorController? controller}) => TestApp(
          home: CustomRefreshIndicator(
            controller: controller,
            builder: buildWithoutIndicator,
            onRefresh: fakeRefresh.refresh,
            child: const DefaultList(itemsCount: 6),
          ),
        );

    await tester.pumpWidget(build(controller: indicatorController));
    await tester.pumpWidget(build());

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(fakeRefresh.called, isTrue);
    expect(indicatorController.state, IndicatorState.idle);
    expect(indicatorController.value, 0.0);

    fakeRefresh.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('CustomRefreshIndicator - hide - before onRefresh completes',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    addTearDown(indicatorController.dispose);

    await tester.pumpWidget(
      TestApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.refresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(indicatorController.state, IndicatorState.loading);

    tester
        .state<CustomRefreshIndicatorState>(find.byType(CustomRefreshIndicator))
        .hide();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(indicatorController.state, IndicatorState.idle);

    fakeRefresh.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(indicatorController.state, IndicatorState.idle);
  });

  testWidgets('CustomRefreshIndicator - stopDrag - hides the indicator',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    addTearDown(indicatorController.dispose);

    await tester.pumpWidget(
      TestApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.text('1')));
    await gesture.moveBy(const Offset(0.0, 50.0));
    await tester.pump();

    expect(indicatorController.state, IndicatorState.dragging);

    indicatorController.stopDrag();
    expect(indicatorController.shouldStopDrag, isTrue);

    await gesture.moveBy(const Offset(0.0, 20.0));
    await tester.pump();

    expect(indicatorController.shouldStopDrag, isFalse);

    await gesture.moveBy(const Offset(0.0, 20.0));
    await tester.pump();
    await gesture.up();
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(indicatorController.state, IndicatorState.idle);
    expect(indicatorController.shouldStopDrag, isFalse);
    expect(fakeRefresh.called, isFalse);
  });

  testWidgets(
      'CustomRefreshIndicator - dragging back below the threshold disarms',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    addTearDown(indicatorController.dispose);

    await tester.pumpWidget(
      TestApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(
            itemsCount: 6,
            physics: BouncingScrollPhysics(),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.text('1')));
    await gesture.moveBy(const Offset(0.0, 140.0));
    await tester.pump();

    expect(indicatorController.state, IndicatorState.armed);
    expect(
      indicatorController.value,
      greaterThanOrEqualTo(CustomRefreshIndicator.armedFromValue),
    );

    await gesture.moveBy(const Offset(0.0, -120.0));
    await tester.pump();

    expect(indicatorController.state, IndicatorState.dragging);
    expect(
      indicatorController.value,
      lessThan(CustomRefreshIndicator.armedFromValue),
    );

    await gesture.up();
    // finish the indicator hide animation
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(fakeRefresh.called, isFalse);
    expect(indicatorController.state, IndicatorState.idle);
  });

  testWidgets(
      'CustomRefreshIndicator - disallows indicator - trailing - while idle',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      TestApp(
        home: CustomRefreshIndicator(
          leadingScrollIndicatorVisible: true,
          trailingScrollIndicatorVisible: false,
          builder: buildWithoutIndicator,
          onRefresh: fakeRefresh.instantRefresh,
          child: const DefaultList(itemsCount: 6),
        ),
      ),
    );

    final context = tester.element(find.byType(DefaultList));

    final trailing = OverscrollIndicatorNotification(leading: false)
      ..dispatch(context);
    expect(trailing.accepted, isFalse);

    final leading = OverscrollIndicatorNotification(leading: true)
      ..dispatch(context);
    expect(leading.accepted, isTrue);
  });

  testWidgets('CustomRefreshIndicator - show - uses the edge of the trigger',
      (WidgetTester tester) async {
    Future<IndicatorEdge?> showWith(IndicatorTrigger trigger) async {
      final indicatorController = IndicatorController();
      addTearDown(indicatorController.dispose);

      await tester.pumpWidget(
        TestApp(
          home: CustomRefreshIndicator(
            key: ValueKey(trigger),
            controller: indicatorController,
            trigger: trigger,
            builder: buildWithoutIndicator,
            onRefresh: fakeRefresh.instantRefresh,
            child: const DefaultList(itemsCount: 6),
          ),
        ),
      );

      final state = tester.state<CustomRefreshIndicatorState>(
        find.byType(CustomRefreshIndicator),
      );
      state.show();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      final edge = indicatorController.edge;

      state.hide();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      return edge;
    }

    expect(await showWith(IndicatorTrigger.leadingEdge), IndicatorEdge.leading);
    expect(
      await showWith(IndicatorTrigger.trailingEdge),
      IndicatorEdge.trailing,
    );
    expect(await showWith(IndicatorTrigger.bothEdges), IndicatorEdge.leading);
  });

  testWidgets(
      'CustomRefreshIndicator - trigger - end edge - hides when the list is dragged back',
      (WidgetTester tester) async {
    final indicatorController = IndicatorController();
    addTearDown(indicatorController.dispose);
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      TestApp(
        home: CustomRefreshIndicator(
          controller: indicatorController,
          builder: buildWithoutIndicator,
          trigger: IndicatorTrigger.trailingEdge,
          onRefresh: fakeRefresh.instantRefresh,
          child: DefaultList(itemsCount: 6, controller: scrollController),
        ),
      ),
    );

    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pump();

    final gesture = await tester.startGesture(tester.getCenter(find.text('6')));
    await gesture.moveBy(const Offset(0.0, -50.0));
    await tester.pump();

    expect(indicatorController.state, IndicatorState.dragging);
    expect(indicatorController.edge, IndicatorEdge.trailing);
    expect(indicatorController.value, greaterThan(0.0));

    await gesture.moveBy(const Offset(0.0, 100.0));
    await tester.pump();

    expect(indicatorController.state, IndicatorState.canceling);

    await gesture.up();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(fakeRefresh.called, isFalse);
    expect(indicatorController.state, IndicatorState.idle);
  });

  group('CustomRefreshIndicator - overlapping refresh cycles', () {
    late List<Completer<void>> refreshes;

    setUp(() => refreshes = <Completer<void>>[]);

    Future<void> onRefresh() {
      final completer = Completer<void>();
      refreshes.add(completer);
      return completer.future;
    }

    Future<void> pumpAnimations(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    CustomRefreshIndicatorState getState(WidgetTester tester) =>
        tester.state<CustomRefreshIndicatorState>(
          find.byType(CustomRefreshIndicator),
        );

    Future<IndicatorController> pumpIndicator(WidgetTester tester) async {
      final indicatorController = IndicatorController();
      addTearDown(indicatorController.dispose);

      await tester.pumpWidget(
        TestApp(
          home: CustomRefreshIndicator(
            controller: indicatorController,
            builder: buildWithoutIndicator,
            onRefresh: onRefresh,
            child: const DefaultList(itemsCount: 6),
          ),
        ),
      );
      return indicatorController;
    }

    testWidgets('hide - stale onRefresh does not hide the next refresh',
        (WidgetTester tester) async {
      final indicatorController = await pumpIndicator(tester);

      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);

      getState(tester).hide();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.idle);

      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);
      expect(refreshes, hasLength(2));

      refreshes[0].complete();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);

      refreshes[1].complete();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.idle);
    });

    testWidgets('refresh - stale onRefresh does not hide the next refresh',
        (WidgetTester tester) async {
      final indicatorController = await pumpIndicator(tester);

      getState(tester).refresh();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);

      getState(tester).hide();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.idle);

      getState(tester).refresh();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);
      expect(refreshes, hasLength(2));

      refreshes[0].complete();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);

      refreshes[1].complete();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.idle);
    });

    testWidgets('show - stale onRefresh does not hide the shown indicator',
        (WidgetTester tester) async {
      final indicatorController = await pumpIndicator(tester);

      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);

      getState(tester).hide();
      await pumpAnimations(tester);

      getState(tester).show();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);

      refreshes[0].complete();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);

      getState(tester).hide();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.idle);
    });
  });

  group('CustomRefreshIndicator - controller change during a refresh', () {
    late Completer<void> refresh;

    // Created here so it belongs to the test zone, otherwise it never resolves
    Future<void> onRefresh() => (refresh = Completer<void>()).future;

    Future<void> pumpAnimations(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    Widget buildIndicator({IndicatorController? controller}) =>
        CustomRefreshIndicator(
          controller: controller,
          builder: buildWithoutIndicator,
          onRefresh: onRefresh,
          child: const DefaultList(itemsCount: 6),
        );

    testWidgets('moves the refresh to the new controller',
        (WidgetTester tester) async {
      final external = IndicatorController();
      addTearDown(external.dispose);

      await tester.pumpWidget(
        TestApp(home: buildIndicator(controller: external)),
      );
      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await pumpAnimations(tester);
      expect(external.state, IndicatorState.loading);

      await tester.pumpWidget(TestApp(home: buildIndicator()));
      final internal = tester
          .state<CustomRefreshIndicatorState>(
            find.byType(CustomRefreshIndicator),
          )
          .controller;

      expect(internal, isNot(same(external)));
      expect(internal.state, IndicatorState.loading);
      expect(internal.value, 1.0);
      expect(internal.edge, IndicatorEdge.leading);
      expect(external.state, IndicatorState.idle);
      expect(external.value, 0.0);
      expect(external.edge, isNull);

      refresh.complete();
      await pumpAnimations(tester);
      expect(internal.state, IndicatorState.idle);

      // The released controller can be used again.
      await tester.pumpWidget(
        TestApp(home: buildIndicator(controller: external)),
      );
      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await pumpAnimations(tester);
      expect(external.state, IndicatorState.loading);

      refresh.complete();
      await pumpAnimations(tester);
      expect(external.state, IndicatorState.idle);
    });

    testWidgets('notifies listeners from outside of the indicator',
        (WidgetTester tester) async {
      final first = IndicatorController();
      final second = IndicatorController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      Widget build(IndicatorController controller) => TestApp(
            home: Column(
              children: [
                AnimatedBuilder(
                  animation: first,
                  builder: (context, _) => Text('first: ${first.state.name}'),
                ),
                AnimatedBuilder(
                  animation: second,
                  builder: (context, _) => Text('second: ${second.state.name}'),
                ),
                Expanded(child: buildIndicator(controller: controller)),
              ],
            ),
          );

      await tester.pumpWidget(build(first));
      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await pumpAnimations(tester);
      expect(find.text('first: loading'), findsOneWidget);
      expect(find.text('second: idle'), findsOneWidget);

      await tester.pumpWidget(build(second));
      expect(tester.takeException(), isNull);
      await tester.pump();

      expect(find.text('first: idle'), findsOneWidget);
      expect(find.text('second: loading'), findsOneWidget);

      refresh.complete();
      await pumpAnimations(tester);
      expect(find.text('second: idle'), findsOneWidget);
    });
  });

  group('CustomRefreshIndicator - removed during a refresh', () {
    late Completer<void> refresh;

    // Created here so it belongs to the test zone, otherwise it never resolves
    Future<void> onRefresh() => (refresh = Completer<void>()).future;

    Future<void> pumpAnimations(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    Widget buildIndicator(IndicatorController controller) =>
        CustomRefreshIndicator(
          controller: controller,
          builder: buildWithoutIndicator,
          onRefresh: onRefresh,
          child: const DefaultList(itemsCount: 6),
        );

    testWidgets('releases the external controller',
        (WidgetTester tester) async {
      final indicatorController = IndicatorController();
      addTearDown(indicatorController.dispose);

      await tester.pumpWidget(
        TestApp(home: buildIndicator(indicatorController)),
      );
      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);

      await tester.pumpWidget(const TestApp(home: SizedBox()));
      expect(indicatorController.state, IndicatorState.idle);
      expect(indicatorController.value, 0.0);
      expect(indicatorController.edge, isNull);

      refresh.complete();
      await pumpAnimations(tester);
      expect(tester.takeException(), isNull);
      expect(indicatorController.state, IndicatorState.idle);

      // The released controller can be used again.
      await tester.pumpWidget(
        TestApp(home: buildIndicator(indicatorController)),
      );
      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);

      refresh.complete();
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.idle);
    });

    testWidgets('notifies listeners from outside of the indicator',
        (WidgetTester tester) async {
      final indicatorController = IndicatorController();
      addTearDown(indicatorController.dispose);

      Widget build({required bool withIndicator}) => TestApp(
            home: Column(
              children: [
                AnimatedBuilder(
                  animation: indicatorController,
                  builder: (context, _) =>
                      Text('state: ${indicatorController.state.name}'),
                ),
                if (withIndicator)
                  Expanded(child: buildIndicator(indicatorController)),
              ],
            ),
          );

      await tester.pumpWidget(build(withIndicator: true));
      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await pumpAnimations(tester);
      expect(find.text('state: loading'), findsOneWidget);

      await tester.pumpWidget(build(withIndicator: false));
      expect(tester.takeException(), isNull);
      await tester.pump();
      expect(find.text('state: idle'), findsOneWidget);

      refresh.complete();
      await pumpAnimations(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('CustomRefreshIndicator - show - axis direction', () {
    Future<void> pumpAnimations(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    Widget buildList({
      Axis scrollDirection = Axis.vertical,
      bool reverse = false,
    }) =>
        ListView.builder(
          scrollDirection: scrollDirection,
          reverse: reverse,
          itemCount: 6,
          itemBuilder: (context, index) => SizedBox(
            width: 200,
            height: 200,
            child: Text((index + 1).toString()),
          ),
        );

    Future<IndicatorController> pumpIndicator(
      WidgetTester tester, {
      required Widget child,
      ScrollNotificationPredicate notificationPredicate =
          defaultScrollNotificationPredicate,
    }) async {
      final indicatorController = IndicatorController();
      addTearDown(indicatorController.dispose);

      await tester.pumpWidget(
        TestApp(
          home: CustomRefreshIndicator(
            controller: indicatorController,
            builder: buildWithoutIndicator,
            notificationPredicate: notificationPredicate,
            onRefresh: () async {},
            child: child,
          ),
        ),
      );
      return indicatorController;
    }

    CustomRefreshIndicatorState getState(WidgetTester tester) =>
        tester.state<CustomRefreshIndicatorState>(
          find.byType(CustomRefreshIndicator),
        );

    testWidgets('horizontal list', (WidgetTester tester) async {
      final indicatorController = await pumpIndicator(
        tester,
        child: buildList(scrollDirection: Axis.horizontal),
      );

      getState(tester).show();
      await pumpAnimations(tester);
      expect(indicatorController.direction, AxisDirection.right);
      expect(indicatorController.side, IndicatorSide.left);

      getState(tester).hide();
      await pumpAnimations(tester);

      getState(tester).show(edge: IndicatorEdge.trailing);
      await pumpAnimations(tester);
      expect(indicatorController.side, IndicatorSide.right);
    });

    testWidgets('reversed list', (WidgetTester tester) async {
      final indicatorController = await pumpIndicator(
        tester,
        child: buildList(reverse: true),
      );

      getState(tester).refresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(indicatorController.direction, AxisDirection.up);
      expect(indicatorController.side, IndicatorSide.bottom);

      await pumpAnimations(tester);
    });

    testWidgets('respects the notification predicate',
        (WidgetTester tester) async {
      final nested = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: 600.0, child: buildList(reverse: true)),
      );

      var indicatorController = await pumpIndicator(tester, child: nested);

      getState(tester).show();
      await pumpAnimations(tester);
      expect(indicatorController.side, IndicatorSide.left);

      await tester.pumpWidget(const SizedBox());
      indicatorController = await pumpIndicator(
        tester,
        child: nested,
        notificationPredicate: (notification) => notification.depth == 1,
      );

      getState(tester).show();
      await pumpAnimations(tester);
      expect(indicatorController.side, IndicatorSide.bottom);
    });

    testWidgets('is not changed by another scrollable during a refresh',
        (WidgetTester tester) async {
      final itemsCount = ValueNotifier<int>(3);
      addTearDown(itemsCount.dispose);
      final refresh = Completer<void>();

      final indicatorController = IndicatorController();
      addTearDown(indicatorController.dispose);

      await tester.pumpWidget(
        TestApp(
          home: CustomRefreshIndicator(
            controller: indicatorController,
            builder: buildWithoutIndicator,
            onRefresh: () => refresh.future,
            child: Column(
              children: [
                const Expanded(child: DefaultList(itemsCount: 6)),
                SizedBox(
                  height: 50,
                  child: ValueListenableBuilder<int>(
                    valueListenable: itemsCount,
                    builder: (context, count, _) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: count,
                      itemBuilder: (context, index) =>
                          const SizedBox(width: 300),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.fling(find.text('1'), const Offset(0.0, 300.0), 1000.0);
      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);
      expect(indicatorController.side, IndicatorSide.top);

      itemsCount.value = 30;
      await tester.pump();
      await tester.pump();
      expect(indicatorController.side, IndicatorSide.top);

      refresh.complete();
      await pumpAnimations(tester);
    });

    testWidgets('when shown right after the first frame',
        (WidgetTester tester) async {
      tester.binding.addPostFrameCallback((_) => getState(tester).show());

      final indicatorController = await pumpIndicator(
        tester,
        child: buildList(scrollDirection: Axis.horizontal),
      );
      expect(indicatorController.state, IndicatorState.dragging);

      await pumpAnimations(tester);
      expect(indicatorController.state, IndicatorState.loading);
      expect(indicatorController.side, IndicatorSide.left);
    });
  });
}
