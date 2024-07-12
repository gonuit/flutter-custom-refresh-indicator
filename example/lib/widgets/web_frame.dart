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
    final theme = Theme.of(context);
    final platform = theme.platform;
    final isWebNotMobile = kIsWeb ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.linux ||
        platform == TargetPlatform.windows &&
            (platform != TargetPlatform.iOS &&
                platform != TargetPlatform.android);

    final Size(width: width, height: height) = MediaQuery.of(context).size;
    final aspectRatio = width / height;

    if (isWebNotMobile && aspectRatio > 0.6) {
      final safeAreaWidth = width.clamp(300.0, 500.0);
      final safeAreaHeight = height - 48;
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Material(
          color: theme.colorScheme.surfaceContainerHighest,
          child: SafeArea(
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
          ),
        ),
      );
    } else {
      return child ?? const SizedBox();
    }
  }
}
