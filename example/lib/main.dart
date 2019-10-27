import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/simple_indicator.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomRefreshIndicator(
        leadingGlowVisible: false,
        trailingGlowVisible: false,
        indicatorBuilder: (context, data) => SimpleIndicator(data: data),
        onRefresh: () => Future.delayed(Duration(seconds: 2)),
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              height: 200,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              height: 200,
              color: Colors.red,
            ),
            // SizedBox(height: 20),
            // Container(
            //   padding: const EdgeInsets.all(20),
            //   height: 200,
            //   color: Colors.red,
            // ),
            // SizedBox(height: 20),
            // Container(
            //   padding: const EdgeInsets.all(20),
            //   height: 200,
            //   color: Colors.red,
            // ),
          ],
        ),
      ),
    );
  }
}
