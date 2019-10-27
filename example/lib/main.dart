import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/inbox_indicator/inbox_indicator.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

const _loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
    "Mauris tristique sit amet mauris eget vehicula. Cras dignissim dolor non "
    "sagittis laoreet. Nunc faucibus placerat est. Etiam ut sem sed leo efficitur"
    " tincidunt nec sed orci. Maecenas consectetur nunc nec dolor ornare mollis."
    " Sed in sodales lacus. Etiam ac diam ac massa ultrices commodo. Quisque "
    "sagittis justo in dolor viverra sodales. Aliquam consequat purus velit, "
    "quis vehicula ligula lacinia vitae.";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomRefreshIndicator(
          leadingGlowVisible: false,
          trailingGlowVisible: false,
          indicatorBuilder: (context, data) => InboxIndicator(data: data),
          onRefresh: () => Future.delayed(Duration(seconds: 2)),
          child: ListView.separated(
            padding: const EdgeInsets.all(15),
            itemBuilder: (BuildContext context, int index) => Element(
              label: "Mail ${index + 1}",
              content: _loremIpsum,
            ),
            itemCount: 20,
            separatorBuilder: (BuildContext context, int index) =>
                SizedBox(height: 20),
          ),
        ),
      ),
    );
  }
}

class Element extends StatelessWidget {
  final String label;
  final String content;

  Element({
    @required this.label,
    @required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(15),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          SizedBox(height: 5),
          Text(
            content,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
