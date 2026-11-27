import 'dart:async';

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
      itemBuilder: (context, index) =>
          SizedBox(height: 200, child: Text((index + 1).toString())),
    );
  }
}
