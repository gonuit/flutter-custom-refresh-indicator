import 'dart:ui';

import 'package:example/screens/presentation_screen.dart';
import 'package:example/widgets/web_frame.dart';
import 'package:flutter/material.dart';

import 'indicators/simple_indicator.dart';
import 'screens/example_indicator_screen.dart';
import 'screens/ice_cream_indicator_screen.dart';
import 'screens/plane_indicator_screen.dart';
import 'screens/check_mark_indicator_screen.dart';
import 'screens/warp_indicator_screen.dart';
import 'utils/mobile_like_scroll_behavior.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MobileLikeScrollBehavior(),
      title: 'CustomRefreshIndicator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
      builder: (context, child) => WebFrame(child: child),
      routes: {
        '/example': (context) => ExampleIndicatorScreen(),
        '/plane': (context) => PlaneIndicatorScreen(),
        '/ice_cream': (context) => IceCreamIndicatorScreen(),
        '/presentation': (context) => PresentationScreen(),
        '/check-mark': (context) => CheckMarkIndicatorScreen(),
        '/warp': (context) => WarpIndicatorScreen(),
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Examples"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: <Widget>[
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text("Presentation"),
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
                child: Text("Simple"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/example',
                arguments: simpleIndicator,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text("Simple with list opacity"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/example',
                arguments: simpleIndicatorWithOpacity,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text("Plane"),
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
                child: Text("Ice cream"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/ice_cream',
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text("Check mark"),
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
                child: Text("Warp indicator"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/warp',
                arguments: simpleIndicator,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
