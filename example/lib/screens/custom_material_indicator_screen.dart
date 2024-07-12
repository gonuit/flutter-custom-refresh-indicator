import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class CustomMaterialIndicatorScreen extends StatefulWidget {
  const CustomMaterialIndicatorScreen({super.key});

  @override
  State<CustomMaterialIndicatorScreen> createState() =>
      _CustomMaterialIndicatorScreenState();
}

class _CustomMaterialIndicatorScreenState
    extends State<CustomMaterialIndicatorScreen> {
  final _controller = IndicatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: const ExampleAppBar(
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE2D8D7),
            ),
          ),
          child: CustomMaterialIndicator(
            controller: _controller,
            clipBehavior: Clip.antiAlias,
            trigger: IndicatorTrigger.bothEdges,
            triggerMode: IndicatorTriggerMode.anywhere,
            onRefresh: () => Future.delayed(const Duration(seconds: 2)),
            indicatorBuilder: (context, controller) {
              return const Icon(
                Icons.ac_unit,
                color: appContentColor,
                size: 30,
              );
            },
            scrollableBuilder: (context, child, controller) {
              return child;
            },
            child: ExampleList(
              itemCount: 12,
              physics: AlwaysScrollableScrollPhysics(
                parent: ClampingWithOverscrollPhysics(state: _controller),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
