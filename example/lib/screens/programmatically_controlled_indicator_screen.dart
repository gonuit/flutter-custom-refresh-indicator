import 'dart:math';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/warp_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class ProgrammaticallyControlled extends StatefulWidget {
  const ProgrammaticallyControlled({super.key});

  @override
  State<ProgrammaticallyControlled> createState() =>
      _ProgrammaticallyControlledState();
}

class _ProgrammaticallyControlledState
    extends State<ProgrammaticallyControlled> {
  final key = GlobalKey<CustomRefreshIndicatorState>();

  final controller = IndicatorController(refreshEnabled: false);

  bool _startedManually = false;

  int _itemsCount = 4;
  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _itemsCount = Random().nextInt(4) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(
        title: "Programmatically-controlled",
        actions: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Row(
                children: [
                  IconButton(
                    onPressed: controller.isIdle
                        ? () {
                            key.currentState!.show(
                              draggingCurve: Curves.easeOutBack,
                            );
                            _startedManually = true;
                          }
                        : null,
                    icon: const Icon(Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: controller.isIdle
                        ? () => key.currentState!.refresh(
                              draggingCurve: Curves.easeOutBack,
                            )
                        : null,
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    onPressed: controller.isLoading && _startedManually
                        ? () {
                            key.currentState!.hide();
                            _startedManually = false;
                          }
                        : null,
                    icon: const Icon(Icons.stop),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: WarpIndicator(
        controller: controller,
        indicatorKey: key,
        onRefresh: onRefresh,
        child: ExampleList(
          leading: const ListHelpBox(
            child: Text(
              'You can use the buttons located in the app bar to control the state of the indicator.',
            ),
          ),
          itemCount: _itemsCount,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
