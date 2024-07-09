import 'package:example/indicators/check_mark_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class CheckMarkIndicatorScreen extends StatefulWidget {
  const CheckMarkIndicatorScreen({super.key});

  @override
  State<CheckMarkIndicatorScreen> createState() =>
      _CheckMarkIndicatorScreenState();
}

class _CheckMarkIndicatorScreenState extends State<CheckMarkIndicatorScreen> {
  bool _useError = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(
        title: "Complete state",
      ),
      body: SafeArea(
        child: CheckMarkIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            if (_useError) {
              throw Exception("Fake exception");
            }
          },
          child: ExampleList(
            leading: Column(
              children: [
                const ListHelpBox(
                  child: Text(
                    'You can specify the "complete state" duration to enable the additional state of the indicator widget.',
                  ),
                ),
                const ListHelpBox(
                  margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'To configure it, please check the durations parameter of the CustomRefreshIndicator widget.',
                  ),
                ),
                ListHelpBox(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Simulate unsuccessful fetches",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: _useError,
                    onChanged: (useError) {
                      setState(() {
                        _useError = useError;
                      });
                    },
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
