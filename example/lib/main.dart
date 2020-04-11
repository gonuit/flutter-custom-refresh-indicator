import 'package:example/indicators/simple_indicator.dart';
import 'package:example/screens/example_indicator_screen.dart';
import 'package:example/screens/ice_cream_indicator_screen.dart';
import 'package:example/screens/plane_indicator_screen.dart';
import 'package:flutter/material.dart';

import 'indicators/emoji_indicator.dart';
import 'indicators/test_indicator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomRefreshIndicator demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
      routes: {
        '/example': (context) => ExampleIndicatorScreen(),
        '/plane': (context) => PlaneIndicatorScreen(),
        '/ice_cream': (context) => IceCreamIndicatorScreen(),
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
            RaisedButton(
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
            RaisedButton(
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
            RaisedButton(
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
            RaisedButton(
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
            RaisedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text("Emoji"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/example',
                arguments: emojiIndicator,
              ),
            ),
            const SizedBox(height: 15),
            RaisedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text("Test indicator"),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/example',
                arguments: testIndicator,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
