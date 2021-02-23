import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';

class PresentationScreen extends StatefulWidget {
  @override
  _PresentationScreenState createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  IndicatorController? _controller;
  @override
  void initState() {
    _controller = IndicatorController(refreshEnabled: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: CustomRefreshIndicator(
          loadingToIdleDuration: const Duration(seconds: 1),
          armedToLoadingDuration: const Duration(seconds: 1),
          draggingToIdleDuration: const Duration(seconds: 1),
          leadingGlowVisible: false,
          trailingGlowVisible: false,
          offsetToArmed: 100.0,
          controller: _controller,
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
          child: DecoratedBox(
            decoration: BoxDecoration(color: appBackgroundColor),
            child: ListView(
              children: [
                AnimatedBuilder(
                  animation: _controller!,
                  builder: (BuildContext context, Widget? child) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(15),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "IndicatorController",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Divider(
                                indent: 5,
                                thickness: 2,
                                color: appBackgroundColor,
                              ),
                              Text(
                                "value: ${_controller!.value.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 18),
                              ),
                              const Divider(
                                indent: 2.5,
                                thickness: 1,
                                color: appBackgroundColor,
                              ),
                              Text(
                                "state: ${_controller!.state.toString().split('.').last}",
                                style: const TextStyle(fontSize: 18),
                              ),
                              const Divider(
                                indent: 2.5,
                                thickness: 1,
                                color: appBackgroundColor,
                              ),
                              Text(
                                "scrollingDirection: ${_controller!.scrollingDirection.toString().split('.').last}",
                                style: const TextStyle(fontSize: 18),
                              ),
                              const Divider(
                                indent: 2.5,
                                thickness: 1,
                                color: appBackgroundColor,
                              ),
                              Text(
                                "direction: ${_controller!.direction.toString().split('.').last}",
                                style: const TextStyle(fontSize: 18),
                              ),
                              const Divider(
                                indent: 2.5,
                                thickness: 1,
                                color: appBackgroundColor,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "isRefreshEnabled: ${_controller!.isRefreshEnabled}",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        _controller!.isRefreshEnabled
                                            ? Colors.red
                                            : Colors.lightGreen,
                                      ),
                                    ),
                                    child: Container(
                                      child: Text(
                                        _controller!.isRefreshEnabled
                                            ? "DISABLE"
                                            : "ENABLE",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _controller!.isRefreshEnabled
                                            ? _controller!.disableRefresh()
                                            : _controller!.enableRefresh(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          builder: (
            BuildContext context,
            Widget child,
            IndicatorController controller,
          ) {
            return Stack(
              children: <Widget>[
                Container(
                  height: 100,
                  color: Colors.amber,
                  child: Center(
                    child: Text(
                      "NOT ARMED",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 100),
                  width: double.infinity,
                  height: 50,
                  color: Colors.greenAccent,
                  child: Center(
                    child: Text(
                      "ARMED",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller!,
                  builder: (context, snapshot) {
                    return Transform.translate(
                      offset: Offset(0.0, 100 * _controller!.value),
                      child: child,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
