import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/plane_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class PlaneIndicatorScreen extends StatefulWidget {
  const PlaneIndicatorScreen({super.key});

  @override
  State<PlaneIndicatorScreen> createState() => _PlaneIndicatorScreenState();
}

class _PlaneIndicatorScreenState extends State<PlaneIndicatorScreen> {
  final _controller = IndicatorController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(),
      body: PlaneIndicator(
        controller: _controller,
        child: ExampleList(
          physics: AlwaysScrollableScrollPhysics(
            parent: ClampingWithOverscrollPhysics(state: _controller),
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
