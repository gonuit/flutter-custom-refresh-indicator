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
      itemCount: 12,
      physics: AlwaysScrollableScrollPhysics(
        parent: _useCustom
            ? ClampingWithOverscrollPhysics(state: _controller)
            : const ClampingScrollPhysics(),
      ),
    );
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: ExampleAppBar(
        elevation: 0,
        actions: [
          Text(
            _useCustom ? "CustomMaterialIndicator" : "RefreshIndicator",
          ),
          Switch(
            value: _useCustom,
            onChanged: _toggleCustom,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE2D8D7),
            ),
          ),
          child: _useCustom
              ? CustomMaterialIndicator(
                  clipBehavior: Clip.antiAlias,
                  trigger: IndicatorTrigger.bothEdges,
                  triggerMode: IndicatorTriggerMode.anywhere,
                  onRefresh: () => Future.delayed(const Duration(seconds: 2)),
                  scrollableBuilder: (context, child, controller) {
                    return child;
                  },
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
