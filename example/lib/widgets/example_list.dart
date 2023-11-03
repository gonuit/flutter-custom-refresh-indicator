import 'package:flutter/material.dart';

import 'example_app_bar.dart';

class ExampleList extends StatelessWidget {
  final int itemCount;
  final bool countElements;
  final bool reverse;
  final Color backgroundColor;

  const ExampleList({
    super.key,
    this.reverse = false,
    this.countElements = false,
    this.backgroundColor = appBackgroundColor,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: const [
          BoxShadow(
            blurRadius: 2,
            color: Colors.black12,
            spreadRadius: 0.5,
            offset: Offset(0.0, .0),
          )
        ],
      ),
      child: ListView.separated(
        reverse: reverse,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        itemBuilder: (BuildContext context, int index) => countElements
            ? Element(
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: appContentColor,
                    ),
                  ),
                ),
              )
            : const Element(),
        itemCount: itemCount,
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
  final Widget? child;

  const Element({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FakeBox(height: 80, width: 80, child: child),
          const SizedBox(width: 20),
          const Expanded(
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
  final Widget? child;
  final double width;
  final double height;

  const FakeBox({
    super.key,
    required this.width,
    required this.height,
    this.child,
  });

  static const _boxDecoration = BoxDecoration(
    color: Color(0xFFE2D8D7),
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
      child: child,
    );
  }
}

class ExampleHorizontalList extends StatelessWidget {
  final int itemCount;
  final bool reverse;
  final Color backgroundColor;
  final bool isHorizontal;

  const ExampleHorizontalList({
    super.key,
    this.reverse = false,
    this.backgroundColor = appBackgroundColor,
    this.itemCount = 4,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: const [
          BoxShadow(
            blurRadius: 2,
            color: Colors.black12,
            spreadRadius: 0.5,
            offset: Offset(0.0, .0),
          )
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        reverse: reverse,
        scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        itemBuilder: (BuildContext context, int index) => const Padding(
          padding: EdgeInsets.all(16.0),
          child: FakeBox(
            width: 300,
            height: 300,
          ),
        ),
        itemCount: itemCount,
      ),
    );
  }
}
