import 'package:flutter/material.dart';

import 'example_app_bar.dart';

class ExampleList extends StatelessWidget {
  final Color backgroundColor;
  const ExampleList([this.backgroundColor = appBackgroundColor]);
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor, boxShadow: [
        BoxShadow(
          blurRadius: 2,
          color: Colors.black12,
          spreadRadius: 0.5,
          offset: Offset(0.0, .0),
        )
      ]),
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) => const Element(),
        itemCount: 4,
        separatorBuilder: (BuildContext context, int index) => const Divider(
          height: 0,
          color: Color(0xFFe2d6ce),
          thickness: 1,
        ),
      ),
    );
  }
}

class Element extends StatelessWidget {
  const Element();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FakeBox(height: 80, width: 80),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FakeBox(height: 8, width: double.infinity),
                FakeBox(height: 8, width: double.infinity),
                FakeBox(height: 8, width: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FakeBox extends StatelessWidget {
  const FakeBox({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  final double width;
  final double height;

  static const _boxDecoration = const BoxDecoration(
    color: const Color(0xFFE2D8D7),
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: width,
      height: height,
      decoration: _boxDecoration,
    );
  }
}
