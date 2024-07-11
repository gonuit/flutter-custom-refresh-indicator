import 'package:example/indicators/ball_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class BallIndicatorScreen extends StatefulWidget {
  const BallIndicatorScreen({super.key});

  @override
  State<BallIndicatorScreen> createState() => _BallIndicatorScreenState();
}

class _BallIndicatorScreenState extends State<BallIndicatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(
        title: "Event based",
      ),
      body: SafeArea(
        child: BallIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 5));
          },
          child: const ExampleList(
            leading: Column(
              children: [
                ListHelpBox(
                  child: Text(
                    r"You can create indicators based on user drag details.",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
