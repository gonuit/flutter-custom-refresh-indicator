import 'dart:ui';

import 'package:material_ui/material_ui.dart';

class MobileLikeScrollBehavior extends MaterialScrollBehavior {
  const MobileLikeScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
