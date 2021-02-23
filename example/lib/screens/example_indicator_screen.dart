import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/custom_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class ExampleIndicatorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CustomIndicatorConfig customIndicator =
        ModalRoute.of(context)!.settings.arguments as CustomIndicatorConfig;
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: CustomRefreshIndicator(
          leadingGlowVisible: false,
          offsetToArmed: 200.0,
          trailingGlowVisible: false,
          builder: customIndicator.builder,
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
          child: const ExampleList(),
        ),
      ),
    );
  }
}
