import 'package:example/indicators/ice_cream_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class IceCreamIndicatorScreen extends StatefulWidget {
  @override
  _IceCreamIndicatorScreenState createState() =>
      _IceCreamIndicatorScreenState();
}

class _IceCreamIndicatorScreenState extends State<IceCreamIndicatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: IceCreamIndicator(
          child: const ExampleList(),
        ),
      ),
    );
  }
}
