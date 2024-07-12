import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/ice_cream_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class IceCreamIndicatorScreen extends StatefulWidget {
  const IceCreamIndicatorScreen({super.key});

  @override
  State<IceCreamIndicatorScreen> createState() =>
      _IceCreamIndicatorScreenState();
}

class _IceCreamIndicatorScreenState extends State<IceCreamIndicatorScreen> {
  final _controller = IndicatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: IceCreamIndicator(
          controller: _controller,
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
