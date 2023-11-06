import 'package:flutter/material.dart';

const appBackgroundColor = Color(0xFFf8f4fc);
const appContentColor = Color(0xff877162);

class ExampleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const ExampleAppBar({
    super.key,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Color(0xff877162),
      ),
      backgroundColor: appBackgroundColor,
      title: Text(
        title ?? "flutter_custom_refresh_indicator",
        style: const TextStyle(
          color: appContentColor,
        ),
      ),
      actions: actions,
      elevation: 3,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
