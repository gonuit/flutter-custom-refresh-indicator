import 'package:flutter/material.dart';

class ExampleList extends StatelessWidget {
  final int itemCount;
  final bool countElements;
  final bool reverse;
  final Color? backgroundColor;
  final ScrollPhysics physics;

  const ExampleList({
    super.key,
    this.reverse = false,
    this.countElements = false,
    this.backgroundColor,
    this.itemCount = 4,
    this.physics = const AlwaysScrollableScrollPhysics(
      parent: ClampingScrollPhysics(),
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
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
        physics: physics,
        reverse: reverse,
        itemBuilder: (BuildContext context, int index) => countElements
            ? Element(
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(),
                  ),
                ),
              )
            : const Element(),
        itemCount: itemCount,
        separatorBuilder: (BuildContext context, int index) => Divider(
          height: 0,
          color: theme.colorScheme.surfaceContainer,
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
  final double? width;
  final double? height;

  const FakeBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: child,
    );
  }
}

class ExampleHorizontalList extends StatelessWidget {
  final int itemCount;
  final bool reverse;
  final Color? backgroundColor;
  final bool isHorizontal;

  const ExampleHorizontalList({
    super.key,
    this.reverse = false,
    this.backgroundColor,
    this.itemCount = 4,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
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
