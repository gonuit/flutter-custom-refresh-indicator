import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:example/widgets/infinite_rotation.dart';
import 'package:flutter/material.dart';

class HorizontalScreen extends StatefulWidget {
  const HorizontalScreen({super.key});

  @override
  State<HorizontalScreen> createState() => _HorizontalScreenState();
}

class _HorizontalScreenState extends State<HorizontalScreen> {
  bool _isHorizontal = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExampleAppBar(
        title: "Multidirectional indicator",
        actions: [
          IconButton(
            tooltip: "Change axis",
            onPressed: () {
              setState(() {
                _isHorizontal = !_isHorizontal;
              });
            },
            icon: _isHorizontal
                ? const Icon(Icons.swap_horizontal_circle)
                : const Icon(Icons.swap_vert_circle),
          )
        ],
      ),
      body: SafeArea(
        child: CustomMaterialIndicator(
          leadingScrollIndicatorVisible: false,
          trailingScrollIndicatorVisible: false,
          triggerMode: IndicatorTriggerMode.anywhere,
          trigger: IndicatorTrigger.bothEdges,
          indicatorBuilder: (context, controller) {
            return InfiniteRotation(
              running: controller.state.isLoading,
              child: const Icon(
                Icons.accessibility,
                size: 30,
              ),
            );
          },
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
          child: ExampleHorizontalList(
            leading: const ListHelpBox(
              child: Text(
                'The indicator can be triggered from both sides. '
                'A button located on the app bar can be used to change the axis.',
              ),
            ),
            itemCount: 4,
            isHorizontal: _isHorizontal,
          ),
        ),
      ),
    );
  }
}
