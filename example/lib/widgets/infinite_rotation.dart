import 'package:flutter/widgets.dart';

class InfiniteRotation extends StatefulWidget {
  final Widget? child;
  final bool running;

  const InfiniteRotation({
    super.key,
    required this.child,
    required this.running,
  });

  @override
  State<InfiniteRotation> createState() => _InfiniteRotationState();
}

class _InfiniteRotationState extends State<InfiniteRotation>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void didUpdateWidget(InfiniteRotation oldWidget) {
    if (oldWidget.running != widget.running) {
      if (widget.running) {
        _startAnimation();
      } else {
        _rotationController.animateTo(0.0,
            duration: const Duration(milliseconds: 50));
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
    _rotationController.repeat();
  }

  @override
  Widget build(BuildContext context) =>
      RotationTransition(turns: _rotationController, child: widget.child);
}
