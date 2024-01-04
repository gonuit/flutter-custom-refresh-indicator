import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class OpacityIndicatorScreen extends StatelessWidget {
  const OpacityIndicatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: CustomMaterialIndicator(
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
          indicatorBuilder: (context, controller) {
            return Icon(
              Icons.ac_unit,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            );
          },
          scrollableBuilder: (context, child, controller) {
            return FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.0)
                  .animate(controller.clamp(0.0, 1.0)),
              child: child,
            );
          },
          child: const ExampleList(itemCount: 6),
        ),
      ),
    );
  }
}
