import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/indicators/custom_indicator.dart';
import 'package:flutter/material.dart';

const _backgroundColor = Color(0xFFf8f4fc);

class ExampleIndicatorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CustomIndicatorConfig customIndicator =
        ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: const Color(0xff877162),
        ),
        backgroundColor: _backgroundColor,
        title: Text(
          "flutter_custom_refresh_indicator",
          style: TextStyle(
            color: const Color(0xff877162),
          ),
        ),
        elevation: 3,
      ),
      body: SafeArea(
        child: CustomRefreshIndicator(
          leadingGlowVisible: false,
          trailingGlowVisible: false,
          childTransformBuilder: customIndicator.childTransformBuilder,
          indicatorBuilder: customIndicator.indicatorBuilder,
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
          child: ListView.separated(
            itemBuilder: (BuildContext context, int index) => Element(),
            itemCount: 4,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              height: 0,
              color: Color(0xFFe2d6ce),
              thickness: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class Element extends StatelessWidget {
  const Element();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _backgroundColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FakeBox(height: 80, width: 80),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FakeBox(height: 8, width: double.infinity),
                FakeBox(height: 8, width: double.infinity),
                FakeBox(height: 8, width: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FakeBox extends StatelessWidget {
  const FakeBox({
    Key key,
    @required this.width,
    @required this.height,
  }) : super(key: key);

  final double width;
  final double height;

  static const _boxDecoration = const BoxDecoration(
    color: const Color(0xFFE2D8D7),
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: width,
      height: height,
      decoration: _boxDecoration,
    );
  }
}
