import 'package:flutter/material.dart';

class InfiniteRatation extends StatefulWidget {
  final Widget? child;
  final bool running;
  final bool reverse;

  InfiniteRatation({
    required this.child,
    required this.running,
    this.reverse = false,
    Key? key,
  }) : super(key: key);
  @override
  InfiniteRatationState createState() => InfiniteRatationState();
}

class InfiniteRatationState extends State<InfiniteRatation>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void didUpdateWidget(InfiniteRatation oldWidget) {
    if (oldWidget.running != widget.running) {
      if (widget.running) {
        _startAnimation();
      } else {
        _rotationController
          ..stop()
          ..value = 0.0;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    if (widget.running) {
      _startAnimation();
    }

    super.initState();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _rotationController.repeat(reverse: widget.reverse);
  }

  @override
  Widget build(BuildContext context) =>
      RotationTransition(turns: _rotationController, child: widget.child);
}
