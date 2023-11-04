import 'package:example/screens/envelope_indicator_screen.dart';
import 'package:example/screens/horizontal_screen.dart';
import 'package:example/screens/presentation_screen.dart';
import 'package:example/screens/programmatically_controlled_indicator_screen.dart';
import 'package:example/widgets/web_frame.dart';
import 'package:flutter/material.dart';

import 'screens/example_indicator_screen.dart';
import 'screens/fetch_more_screen.dart';
import 'screens/ice_cream_indicator_screen.dart';
import 'screens/plane_indicator_screen.dart';
import 'screens/check_mark_indicator_screen.dart';
import 'screens/warp_indicator_screen.dart';
import 'utils/mobile_like_scroll_behavior.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MobileLikeScrollBehavior(),
      title: 'CustomRefreshIndicator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
      builder: (context, child) => WebFrame(child: child),
      routes: {
        '/example': (context) => const ExampleIndicatorScreen(),
        '/plane': (context) => const PlaneIndicatorScreen(),
        '/ice-cream': (context) => const IceCreamIndicatorScreen(),
        '/presentation': (context) => const PresentationScreen(),
        '/check-mark': (context) => const CheckMarkIndicatorScreen(),
        '/warp': (context) => const WarpIndicatorScreen(),
        '/envelope': (context) => const EnvelopIndicatorScreen(),
        '/fetch-more': (context) => const FetchMoreScreen(),
        '/horizontal': (context) => const HorizontalScreen(),
        '/programmatically-controlled': (context) => const ProgrammaticallyControlled(),
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
          padding: const EdgeInsets.all(15),
          children: <Widget>[
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Controller presentation"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/presentation',
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Multidirectional indicator"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/horizontal',
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Custom material indicator with list opacity"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/example',
              ),
            ),
            const SizedBox(height: 15),
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
            const SizedBox(height: 15),
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
            const SizedBox(height: 15),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Witch complete state"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/check-mark',
              ),
            ),
            const SizedBox(height: 15),
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
            const SizedBox(height: 15),
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
            const SizedBox(height: 15),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Programmatically-controlled warp"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/programmatically-controlled',
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("Swipe to fetch more"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/fetch-more',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
