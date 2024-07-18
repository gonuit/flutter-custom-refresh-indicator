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

  bool _useCustom = true;

  void _toggleCustom(bool useCustom) {
    // if no change exit
    if (_useCustom == useCustom) return;

    setState(() {
      _useCustom = useCustom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = ExampleList(
      leading: const Column(
        children: [
          ListHelpBox(
            child: Text(
              "Use the toggle on the app bar to change between CustomMaterialIndicator "
              "and the built-in RefreshIndicator widget.",
            ),
          ),
          ListHelpBox(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              "Can you spot the difference? 😉",
            ),
          ),
        ],
      ),
      itemCount: 12,
      physics: AlwaysScrollableScrollPhysics(
        parent: _useCustom
            ? ClampingWithOverscrollPhysics(state: _controller)
            : const ClampingScrollPhysics(),
      ),
    );
    return Scaffold(
      appBar: ExampleAppBar(
        elevation: 0,
        title: _useCustom ? "CustomMaterialIndicator" : "RefreshIndicator",
        actions: [
          Switch(
            value: _useCustom,
            onChanged: _toggleCustom,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: _useCustom
              ? CustomMaterialIndicator(
                  clipBehavior: Clip.antiAlias,
                  trigger: IndicatorTrigger.bothEdges,
                  triggerMode: IndicatorTriggerMode.anywhere,
                  onRefresh: () => Future.delayed(const Duration(seconds: 2)),
                  child: child,
                )
              : RefreshIndicator(
                  onRefresh: () => Future.delayed(const Duration(seconds: 2)),
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  child: child,
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
