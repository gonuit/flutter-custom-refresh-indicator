import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
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
  final _controller = IndicatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(
        title: "Drag details",
      ),
      body: SafeArea(
        child: BallIndicator(
          controller: _controller,
          ballColors: const [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.amber,
            Colors.pink,
            Colors.purple,
            Colors.cyan,
            Colors.orange,
            Colors.yellow,
          ],
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 5));
          },
          child: ExampleList(
            physics: AlwaysScrollableScrollPhysics(
              parent: ClampingWithOverscrollPhysics(state: _controller),
            ),
            leading: Column(
              children: [
                const ListHelpBox(
                  child: Text(
                    r"You can create indicators based on user drag details.",
                  ),
                ),
                ListHelpBox(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (_, __) => Column(
                      children: [
                        const Expanded(
                          child: Text(
                            "This indicator is based on the local position of the drag details, "
                            "which is currently: ",
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListHelpBox(
                          icon: Icons.data_object_sharp,
                          child: Text(
                            "${_controller.dragDetails?.localPosition}",
                          ),
                        )
                      ],
                    ),
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
