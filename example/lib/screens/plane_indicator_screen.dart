import 'package:example/indicators/plane_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

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
      body: PlaneIndicator(
        child: const ExampleList(),
      ),
    );
  }
}
