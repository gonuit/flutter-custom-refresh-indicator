import 'package:flutter/material.dart';

class ExampleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final double elevation;

  const ExampleAppBar({
    super.key,
    this.title,
    this.actions,
    this.elevation = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title ?? "custom_refresh_indicator",
      ),
      actions: actions,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
