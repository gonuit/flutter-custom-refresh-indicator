import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _childKey = ValueKey('child');
const _childWidth = 40.0;
const _childHeight = 40.0;
const _parentSize = Size(400.0, 600.0);

void main() {
  IndicatorController buildController({
    IndicatorEdge? edge,
    AxisDirection direction = AxisDirection.down,
    IndicatorState? state,
    double? value,
  }) {
    final controller = IndicatorController();
    controller.setAxisDirection(direction);
    controller.setIndicatorEdge(edge);
    if (state != null) controller.setIndicatorState(state);
    if (value != null) controller.setValue(value);
    return controller;
  }

  Future<void> pumpContainer(
    WidgetTester tester, {
    required IndicatorController controller,
    double displacement = 40.0,
    double edgeOffset = 0.0,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: textDirection,
        child: Center(
          child: SizedBox(
            width: _parentSize.width,
            height: _parentSize.height,
            child: Stack(
              children: <Widget>[
                PositionedIndicatorContainer(
                  controller: controller,
                  displacement: displacement,
                  edgeOffset: edgeOffset,
                  child: const SizedBox(
                    key: _childKey,
                    width: _childWidth,
                    height: _childHeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Positioned getPositioned(WidgetTester tester) =>
      tester.widget<Positioned>(find.byType(Positioned));

  Align getOuterAlign(WidgetTester tester) =>
      tester.widget<Align>(find.byType(Align).first);

  Align getInnerAlign(WidgetTester tester) =>
      tester.widget<Align>(find.byType(Align).last);

  EdgeInsets getPadding(WidgetTester tester) =>
      tester.widget<Padding>(find.byType(Padding)).padding as EdgeInsets;

  Rect getChildRect(WidgetTester tester) =>
      tester.getRect(find.byKey(_childKey));

  Rect getParentRect(WidgetTester tester) => tester.getRect(find.byType(Stack));

  testWidgets('PositionedIndicatorContainer - no edge renders nothing',
      (WidgetTester tester) async {
    final controller = buildController();
    addTearDown(controller.dispose);

    await pumpContainer(tester, controller: controller);

    expect(controller.side, IndicatorSide.none);
    expect(find.byKey(_childKey), findsNothing);
    expect(find.byType(Positioned), findsNothing);
    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(PositionedIndicatorContainer),
          matching: find.byType(SizedBox),
        ),
      ),
      Size.zero,
    );
  });

  testWidgets('PositionedIndicatorContainer - top side',
      (WidgetTester tester) async {
    final controller = buildController(
      direction: AxisDirection.down,
      edge: IndicatorEdge.leading,
    );
    addTearDown(controller.dispose);

    await pumpContainer(tester, controller: controller, edgeOffset: 12.0);

    expect(controller.side, IndicatorSide.top);

    final positioned = getPositioned(tester);
    expect(positioned.top, 12.0);
    expect(positioned.bottom, isNull);
    expect(positioned.left, 0);
    expect(positioned.right, 0);

    expect(getOuterAlign(tester).heightFactor, 0.0);
    expect(getOuterAlign(tester).widthFactor, isNull);
    expect(
        getOuterAlign(tester).alignment, const AlignmentDirectional(-1.0, 1.0));
    expect(getInnerAlign(tester).alignment, Alignment.topCenter);
    expect(getPadding(tester), const EdgeInsets.only(top: 40.0));
  });

  testWidgets('PositionedIndicatorContainer - bottom side',
      (WidgetTester tester) async {
    final controller = buildController(
      direction: AxisDirection.down,
      edge: IndicatorEdge.trailing,
    );
    addTearDown(controller.dispose);

    await pumpContainer(tester, controller: controller, edgeOffset: 12.0);

    expect(controller.side, IndicatorSide.bottom);

    final positioned = getPositioned(tester);
    expect(positioned.top, isNull);
    expect(positioned.bottom, 12.0);
    expect(positioned.left, 0);
    expect(positioned.right, 0);

    expect(getOuterAlign(tester).heightFactor, 0.0);
    expect(getOuterAlign(tester).widthFactor, isNull);
    expect(
      getOuterAlign(tester).alignment,
      const AlignmentDirectional(-1.0, -1.0),
    );
    expect(getInnerAlign(tester).alignment, Alignment.bottomCenter);
    expect(getPadding(tester), const EdgeInsets.only(bottom: 40.0));
  });

  testWidgets('PositionedIndicatorContainer - left side',
      (WidgetTester tester) async {
    final controller = buildController(
      direction: AxisDirection.right,
      edge: IndicatorEdge.leading,
    );
    addTearDown(controller.dispose);

    await pumpContainer(tester, controller: controller, edgeOffset: 12.0);

    expect(controller.side, IndicatorSide.left);

    final positioned = getPositioned(tester);
    expect(positioned.top, 0);
    expect(positioned.bottom, 0);
    expect(positioned.left, 12.0);
    expect(positioned.right, isNull);

    expect(getOuterAlign(tester).widthFactor, 0.0);
    expect(getOuterAlign(tester).heightFactor, isNull);
    expect(
      getOuterAlign(tester).alignment,
      const AlignmentDirectional(1.0, -1.0),
    );
    expect(getInnerAlign(tester).alignment, Alignment.centerLeft);
    expect(getPadding(tester), const EdgeInsets.only(left: 40.0));
  });

  testWidgets('PositionedIndicatorContainer - right side',
      (WidgetTester tester) async {
    final controller = buildController(
      direction: AxisDirection.left,
      edge: IndicatorEdge.leading,
    );
    addTearDown(controller.dispose);

    await pumpContainer(tester, controller: controller, edgeOffset: 12.0);

    expect(controller.side, IndicatorSide.right);

    final positioned = getPositioned(tester);
    expect(positioned.top, 0);
    expect(positioned.bottom, 0);
    expect(positioned.left, isNull);
    expect(positioned.right, 12.0);

    expect(getOuterAlign(tester).widthFactor, 0.0);
    expect(getOuterAlign(tester).heightFactor, isNull);
    expect(
      getOuterAlign(tester).alignment,
      const AlignmentDirectional(-1.0, -1.0),
    );
    expect(getInnerAlign(tester).alignment, Alignment.centerRight);
    expect(getPadding(tester), const EdgeInsets.only(right: 40.0));
  });

  testWidgets('PositionedIndicatorContainer - defaults',
      (WidgetTester tester) async {
    final controller = buildController(edge: IndicatorEdge.leading);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: <Widget>[
            PositionedIndicatorContainer(
              controller: controller,
              child: const SizedBox(key: _childKey, width: 40, height: 40),
            ),
          ],
        ),
      ),
    );

    expect(getPositioned(tester).top, 0.0);
    expect(getPadding(tester), const EdgeInsets.only(top: 40.0));
  });

  testWidgets('PositionedIndicatorContainer - slides with the controller value',
      (WidgetTester tester) async {
    final controller = buildController(
      edge: IndicatorEdge.leading,
      state: IndicatorState.dragging,
    );
    addTearDown(controller.dispose);

    await pumpContainer(tester, controller: controller);

    final atZero = getChildRect(tester).top;

    controller.setValue(0.5);
    await tester.pump();
    final atHalf = getChildRect(tester).top;

    controller.setValue(1.0);
    await tester.pump();
    final atOne = getChildRect(tester).top;

    expect(atHalf, greaterThan(atZero));
    expect(atOne, greaterThan(atHalf));
    expect(atOne - atZero, _childHeight + 40.0);
  });

  testWidgets(
      'PositionedIndicatorContainer - slides without rebuilding the tree',
      (WidgetTester tester) async {
    var builds = 0;
    final controller = buildController(
      edge: IndicatorEdge.leading,
      state: IndicatorState.dragging,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: <Widget>[
            PositionedIndicatorContainer(
              controller: controller,
              child: Builder(
                builder: (context) {
                  builds++;
                  return const SizedBox(key: _childKey, width: 40, height: 40);
                },
              ),
            ),
          ],
        ),
      ),
    );

    final buildsAfterMount = builds;
    final before = getChildRect(tester).top;

    controller.setValue(1.0);
    await tester.pump();

    expect(getChildRect(tester).top, greaterThan(before));
    expect(builds, buildsAfterMount);
  });

  testWidgets('PositionedIndicatorContainer - finalizing pins the end offset',
      (WidgetTester tester) async {
    final controller = buildController(
      edge: IndicatorEdge.leading,
      state: IndicatorState.finalizing,
      value: 0.25,
    );
    addTearDown(controller.dispose);

    await pumpContainer(tester, controller: controller);

    final atQuarter = getChildRect(tester).top;

    controller.setValue(1.0);
    await tester.pump();

    expect(getChildRect(tester).top, atQuarter);
  });

  testWidgets('PositionedIndicatorContainer - displacement offsets the child',
      (WidgetTester tester) async {
    final controller = buildController(
      edge: IndicatorEdge.leading,
      value: 1.0,
    );
    addTearDown(controller.dispose);

    await pumpContainer(tester, controller: controller, displacement: 40.0);
    final atDefault = getChildRect(tester).top;

    await pumpContainer(tester, controller: controller, displacement: 100.0);
    final atLarger = getChildRect(tester).top;

    expect(atLarger - atDefault, 60.0);
  });

  testWidgets(
      'PositionedIndicatorContainer - edgeOffset composes with displacement',
      (WidgetTester tester) async {
    final controller = buildController(
      edge: IndicatorEdge.leading,
      value: 1.0,
    );
    addTearDown(controller.dispose);

    await pumpContainer(tester, controller: controller);
    final withoutEdgeOffset = getChildRect(tester).top;

    await pumpContainer(tester, controller: controller, edgeOffset: 30.0);
    final withEdgeOffset = getChildRect(tester).top;

    expect(withEdgeOffset - withoutEdgeOffset, 30.0);
  });

  testWidgets('PositionedIndicatorContainer - left side stays left in RTL',
      (WidgetTester tester) async {
    final controller = buildController(
      direction: AxisDirection.right,
      edge: IndicatorEdge.leading,
      value: 1.0,
    );
    addTearDown(controller.dispose);

    await pumpContainer(
      tester,
      controller: controller,
      textDirection: TextDirection.rtl,
    );

    expect(controller.side, IndicatorSide.left);
    expect(
      getChildRect(tester).left - getParentRect(tester).left,
      lessThan(_parentSize.width / 2),
    );
  });

  testWidgets('PositionedIndicatorContainer - right side stays right in RTL',
      (WidgetTester tester) async {
    final controller = buildController(
      direction: AxisDirection.left,
      edge: IndicatorEdge.leading,
      value: 1.0,
    );
    addTearDown(controller.dispose);

    await pumpContainer(
      tester,
      controller: controller,
      textDirection: TextDirection.rtl,
    );

    expect(controller.side, IndicatorSide.right);
    expect(
      getParentRect(tester).right - getChildRect(tester).right,
      lessThan(_parentSize.width / 2),
    );
  });
}
