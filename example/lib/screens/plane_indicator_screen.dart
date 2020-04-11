import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/plane_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PlaneIndicatorScreen extends StatefulWidget {
  @override
  _PlaneIndicatorScreenState createState() => _PlaneIndicatorScreenState();
}

class _PlaneIndicatorScreenState extends State<PlaneIndicatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: CustomRefreshIndicator(
          leadingGlowVisible: false,
          offsetToArmed: 200.0,
          trailingGlowVisible: false,
          onRefresh: () => Future.delayed(const Duration(seconds: 3)),
          child: const ExampleList(),
          builder: (BuildContext context, Widget child,
              IndicatorController controller) {
            return PlaneIndicator(
              child: child,
              controller: controller,
            );
          },
        ),
      ),
    );
  }
}
