import 'package:flutter/material.dart';

const appBackgroundColor = Color(0xFFf8f4fc);

class ExampleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ExampleAppBar();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: const Color(0xff877162),
      ),
      backgroundColor: appBackgroundColor,
      title: Text(
        "flutter_custom_refresh_indicator",
        style: TextStyle(
          color: const Color(0xff877162),
        ),
      ),
      elevation: 3,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
