import 'package:example/screens/ball_indicator_screen.dart';
import 'package:example/screens/envelope_indicator_screen.dart';
import 'package:example/screens/horizontal_screen.dart';
import 'package:example/screens/presentation_screen.dart';
import 'package:example/screens/programmatically_controlled_indicator_screen.dart';
import 'package:example/widgets/web_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/custom_material_indicator_screen.dart';
import 'screens/fetch_more_screen.dart';
import 'screens/ice_cream_indicator_screen.dart';
import 'screens/plane_indicator_screen.dart';
import 'screens/check_mark_indicator_screen.dart';
import 'screens/warp_indicator_screen.dart';
import 'utils/mobile_like_scroll_behavior.dart';
import 'widgets/example_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MobileLikeScrollBehavior(),
      title: 'CustomRefreshIndicator Demo',
      theme: ThemeData.dark(),
      home: const MainScreen(),
      builder: (context, child) => WebFrame(child: child),
      routes: {
        '/presentation': (context) => const PresentationScreen(),
        '/example': (context) => const CustomMaterialIndicatorScreen(),
        '/plane': (context) => const PlaneIndicatorScreen(),
        '/ice-cream': (context) => const IceCreamIndicatorScreen(),
        '/drag-details': (context) => const BallIndicatorScreen(),
        '/check-mark': (context) => const CheckMarkIndicatorScreen(),
        '/warp': (context) => const WarpIndicatorScreen(),
        '/envelope': (context) => const EnvelopIndicatorScreen(),
        '/fetch-more': (context) => const FetchMoreScreen(),
        '/horizontal': (context) => const HorizontalScreen(),
        '/programmatically-controlled': (context) =>
            const ProgrammaticallyControlled(),
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Examples"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Overview"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/presentation',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Custom Material Indicator"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/example',
              ),
            ),
            const ListSection(label: "Use cases"),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Multidirectional"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/horizontal',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Complete state"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/check-mark',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Drag details (Ball)"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/drag-details',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Programmatically-controlled (Warp)"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/programmatically-controlled',
              ),
            ),
            const ListSection(label: "Indicator examples"),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Pull up to fetch more"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/fetch-more',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Plane"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/plane',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Ice cream"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/ice-cream',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Warp indicator"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/warp',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Envelope indicator"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/envelope',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
