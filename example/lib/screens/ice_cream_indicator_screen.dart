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
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: ExampleAppBar(),
      body: SafeArea(
        child: IceCreamIndicator(
          child: ExampleList(),
        ),
      ),
    );
  }
}
