import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/blur_indicator.dart';
import 'package:example/indicators/simple_indicator.dart';
import 'package:example/screens/example_indicator_screen.dart';
import 'package:flutter/material.dart';

import 'indicators/inbox_indicator/inbox_indicator.dart';

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
              onPressed: () => Navigator.pushNamed(context, '/example',
                  arguments: (context, data) => SimpleIndicatorContainer(
                        data: data,
                        child: SimpleIndicatorContent(
                          data: data,
                        ),
                      )),
            ),
            SizedBox(height: 15),
            RaisedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text("Letter"),
              ),
              onPressed: () => Navigator.pushNamed(context, '/example',
                  arguments: (context, data) => InboxIndicator(data: data)),
            ),
            SizedBox(height: 15),
            RaisedButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text("Blur"),
              ),
              onPressed: () => Navigator.pushNamed(context, '/example',
                  arguments: (context, data) => BlurIndicator(data: data)),
            ),
          ],
        ),
      ),
    );
  }
}
