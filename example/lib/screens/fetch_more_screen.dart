import 'package:example/indicators/fetch_more_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class FetchMoreScreen extends StatefulWidget {
  const FetchMoreScreen({super.key});

  @override
  State<FetchMoreScreen> createState() => _FetchMoreScreenState();
}

class _FetchMoreScreenState extends State<FetchMoreScreen> {
  int _itemsCount = 10;

  Future<void> _fetchMore() async {
    // Simulate fetch time
    await Future<void>.delayed(const Duration(seconds: 2));
    // make sure that the widget is still mounted.
    if (!mounted) return;
    // Add more fake elements
    setState(() {
      _itemsCount += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleAppBar(title: "Pull to fetch more"),
      body: FetchMoreIndicator(
        onAction: _fetchMore,
        child: ExampleList(
          leading: const ListHelpBox(
            child: Text(
              "Scroll to the end of the list "
              "and pull up to retrieve more rows.",
            ),
          ),
          itemCount: _itemsCount,
          countElements: true,
        ),
      ),
    );
  }
}
