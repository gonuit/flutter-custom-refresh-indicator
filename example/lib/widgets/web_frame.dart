import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebFrame extends StatelessWidget {
  final Widget? child;

  const WebFrame({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isWebNotMobile =
        kIsWeb && (defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android);
    if (isWebNotMobile) {
      final safeAreaWidth = math.max<double>(MediaQuery.of(context).size.width, 300);
      final safeAreaHeight = MediaQuery.of(context).size.height - 48;
      return SafeArea(
        child: Center(
          child: SizedBox(
            width: safeAreaWidth,
            height: safeAreaHeight,
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 6,
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 10,
                        blurRadius: 10,
                        color: Colors.black12,
                      )
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return child ?? const SizedBox();
    }
  }
}
