import 'package:example/indicators/envelope_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class EnvelopIndicatorScreen extends StatelessWidget {
  const EnvelopIndicatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(
        title: "Envelope indicator",
      ),
      body: EnvelopRefreshIndicator(
        child: const ExampleList(),
        accent: appContentColor,
        onRefresh: () => Future<void>.delayed(const Duration(seconds: 2)),
      ),
    );
  }
}
