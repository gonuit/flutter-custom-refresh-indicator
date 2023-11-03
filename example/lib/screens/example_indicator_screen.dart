import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class ExampleIndicatorScreen extends StatelessWidget {
  const ExampleIndicatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: CustomRefreshIndicator(
          leadingScrollIndicatorVisible: false,
          trailingScrollIndicatorVisible: false,
          builder: MaterialIndicatorDelegate(
            builder: (context, controller) {
              return Icon(
                Icons.ac_unit,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              );
            },
            scrollableBuilder: (context, child, controller) {
              return Opacity(
                opacity: 1.0 - controller.value.clamp(0.0, 1.0),
                child: child,
              );
            },
          ).call,
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
          child: const ExampleList(itemCount: 6),
        ),
      ),
    );
  }
}
