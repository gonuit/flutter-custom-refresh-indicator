import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/envelope_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class EnvelopIndicatorScreen extends StatefulWidget {
  const EnvelopIndicatorScreen({super.key});

  @override
  State<EnvelopIndicatorScreen> createState() => _EnvelopIndicatorScreenState();
}

class _EnvelopIndicatorScreenState extends State<EnvelopIndicatorScreen> {
  final _controller = IndicatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(
        title: "Envelope indicator",
      ),
      body: EnvelopRefreshIndicator(
        controller: _controller,
        onRefresh: () => Future<void>.delayed(const Duration(seconds: 2)),
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
