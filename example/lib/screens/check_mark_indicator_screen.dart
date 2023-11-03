import 'package:example/indicators/check_mark_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class CheckMarkIndicatorScreen extends StatefulWidget {
  const CheckMarkIndicatorScreen({super.key});

  @override
  State<CheckMarkIndicatorScreen> createState() =>
      _CheckMarkIndicatorScreenState();
}

class _CheckMarkIndicatorScreenState extends State<CheckMarkIndicatorScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: ExampleAppBar(),
      body: SafeArea(
        child: CheckMarkIndicator(
          child: ExampleList(),
        ),
      ),
    );
  }
}
