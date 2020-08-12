import 'package:example/indicators/check_mark_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CheckMarkIndicatorScreen extends StatefulWidget {
  @override
  _CheckMarkIndicatorScreenState createState() =>
      _CheckMarkIndicatorScreenState();
}

class _CheckMarkIndicatorScreenState extends State<CheckMarkIndicatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: CheckMarkIndicator(
          child: const ExampleList(),
        ),
      ),
    );
  }
}
