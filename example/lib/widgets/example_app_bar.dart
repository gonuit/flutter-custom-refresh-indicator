import 'package:flutter/material.dart';

const appBackgroundColor = Color(0xFFf8f4fc);

class ExampleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ExampleAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Color(0xff877162),
      ),
      backgroundColor: appBackgroundColor,
      title: const Text(
        "flutter_custom_refresh_indicator",
        style: TextStyle(
          color: Color(0xff877162),
        ),
      ),
      elevation: 3,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
