import 'package:flutter/material.dart';

class ExampleList extends StatelessWidget {
  final int itemCount;
  final bool countElements;
  final bool reverse;
  final Color? backgroundColor;
  final ScrollPhysics physics;
  final Widget? leading;

  const ExampleList({
    super.key,
    this.reverse = false,
    this.countElements = false,
    this.backgroundColor,
    this.itemCount = 4,
    this.physics = const AlwaysScrollableScrollPhysics(
      parent: ClampingScrollPhysics(),
    ),
    this.leading,
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
      child: CustomScrollView(
        physics: physics,
        reverse: reverse,
        slivers: [
          if (leading != null && !reverse) SliverToBoxAdapter(child: leading!),
          SliverList.separated(
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
          if (leading != null && reverse) SliverToBoxAdapter(child: leading!),
        ],
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
          AppCard(height: 80, width: 80, child: child),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(height: 8, width: double.infinity),
                AppCard(height: 8, width: double.infinity),
                AppCard(height: 8, width: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsets? margin;

  const AppCard({
    super.key,
    this.width,
    this.height,
    this.child,
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
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
  final Widget? leading;

  const ExampleHorizontalList({
    super.key,
    this.reverse = false,
    this.backgroundColor,
    this.itemCount = 4,
    this.isHorizontal = true,
    this.leading,
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
      child: Column(
        children: [
          if (isHorizontal && leading != null) leading!,
          Expanded(
            child: CustomScrollView(
              reverse: reverse,
              scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              slivers: [
                if (!isHorizontal && leading != null && !reverse)
                  SliverToBoxAdapter(child: leading!),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList.separated(
                    itemBuilder: (BuildContext context, int index) =>
                        const AppCard(
                      margin: EdgeInsets.zero,
                      width: 300,
                      height: 300,
                    ),
                    itemCount: itemCount,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox.square(dimension: 16),
                  ),
                ),
                if (!isHorizontal && leading != null && reverse)
                  SliverToBoxAdapter(child: leading!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListSection extends StatelessWidget {
  final String label;
  const ListSection({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
          child: Text(label),
        ),
        const Divider(height: 8),
        const SizedBox(height: 8),
      ],
    );
  }
}

class ListHelpBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final IconData? icon;

  const ListHelpBox({
    super.key,
    this.icon,
    this.margin = const EdgeInsets.all(16.0),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: margin,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Icon(
                icon ?? Icons.info_outline,
                color: theme.colorScheme.onSurface,
              ),
              const VerticalDivider(
                width: 24,
                indent: 4,
                endIndent: 4,
              ),
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
