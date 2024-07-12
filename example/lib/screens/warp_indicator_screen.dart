import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

import '../indicators/warp_indicator.dart';

class WarpIndicatorScreen extends StatefulWidget {
  const WarpIndicatorScreen({super.key});

  @override
  State<WarpIndicatorScreen> createState() => _WarpIndicatorScreenState();
}

class _WarpIndicatorScreenState extends State<WarpIndicatorScreen> {
  final _controller = IndicatorController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: WarpIndicator(
          controller: _controller,
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
          child: ExampleList(
            physics: AlwaysScrollableScrollPhysics(
              parent: ClampingWithOverscrollPhysics(state: _controller),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
