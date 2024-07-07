import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class FetchMoreIndicator extends StatelessWidget {
  final Widget child;
  final VoidCallback onAction;

  const FetchMoreIndicator({
    super.key,
    required this.child,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    const height = 150.0;
    return CustomRefreshIndicator(
      onRefresh: () async => onAction(),
      trigger: IndicatorTrigger.trailingEdge,
      trailingScrollIndicatorVisible: false,
      leadingScrollIndicatorVisible: true,
      durations: const RefreshIndicatorDurations(
        completeDuration: Duration(seconds: 1),
      ),
      child: child,
      builder: (
        BuildContext context,
        Widget child,
        IndicatorController controller,
      ) {
        return AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final dy = controller.value.clamp(0.0, 1.25) *
                  -(height - (height * 0.25));
              return Stack(
                children: [
                  child,
                  PositionedIndicatorContainer(
                    controller: controller,
                    displacement: 0,
                    child: Container(
                        padding: const EdgeInsets.all(8.0),
                        transform: Matrix4.translationValues(0.0, dy, 0.0),
                        child: switch (controller.state) {
                          IndicatorState.idle => null,
                          IndicatorState.dragging ||
                          IndicatorState.canceling ||
                          IndicatorState.armed ||
                          IndicatorState.settling =>
                            const Column(
                              children: [
                                Icon(Icons.keyboard_arrow_up),
                                Text("Pull to fetch more"),
                              ],
                            ),
                          IndicatorState.loading => Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  width: 16,
                                  height: 16,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const Text("Fetching..."),
                              ],
                            ),
                          IndicatorState.complete ||
                          IndicatorState.finalizing =>
                            const Text("Fetched 🚀"),
                        }),
                  ),
                ],
              );
            });
      },
    );
  }
}
