import 'dart:async';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/widgets.dart';

/// Manipulates the refresh indicator state
class FakeRefresh {
  var _completer = Completer<void>();

  bool _called = false;
  bool get called => _called;

  // Created here so it belongs to the test zone, otherwise it never resolves
  Future<void> refresh() {
    _called = true;
    return (_completer = Completer<void>()).future;
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

/// The application shell of the tested widgets.
class TestApp extends StatelessWidget {
  final Widget home;
  final ScrollBehavior scrollBehavior;

  const TestApp({
    super.key,
    required this.home,
    this.scrollBehavior = const StretchingScrollBehavior(),
  });

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF000000),
      builder: (context, _) => ScrollConfiguration(
        behavior: scrollBehavior,
        child: home,
      ),
    );
  }
}

/// Uses the stretching overscroll indicator on Android.
class StretchingScrollBehavior extends ScrollBehavior {
  const StretchingScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return StretchingOverscrollIndicator(
          axisDirection: details.direction,
          child: child,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return child;
    }
  }
}
