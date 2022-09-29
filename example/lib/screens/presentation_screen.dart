import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:flutter/material.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({Key? key}) : super(key: key);

  @override
  _PresentationScreenState createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final _controller = IndicatorController(refreshEnabled: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: CustomRefreshIndicator(
          edge: IndicatorTriggerEdge.both,
          loadingToIdleDuration: const Duration(seconds: 1),
          armedToLoadingDuration: const Duration(seconds: 1),
          draggingToIdleDuration: const Duration(seconds: 1),
          leadingScrollIndicatorVisible: false,
          trailingScrollIndicatorVisible: false,
          offsetToArmed: 100.0,
          controller: _controller,
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
          child: DecoratedBox(
            decoration:
                const BoxDecoration(color: appBackgroundColor, boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 4)
            ]),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              slivers: [
                SliverFillViewport(
                  delegate: SliverChildListDelegate([
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (BuildContext context, Widget? child) {
                        return AnimatedAlign(
                          curve: Curves.easeInOut,
                          duration: const Duration(seconds: 1),
                          alignment: _controller.side.isNone
                              ? Alignment.center
                              : _controller.side.isBottom
                                  ? Alignment.bottomCenter
                                  : Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.all(15),
                            padding: const EdgeInsets.all(15),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Center(
                                  child: Text(
                                    "IndicatorController",
                                    style: TextStyle(
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
                                  "value: ${_controller.value.toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const Divider(
                                  indent: 2.5,
                                  thickness: 1,
                                  color: appBackgroundColor,
                                ),
                                Text(
                                  "state: ${_controller.state.name}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const Divider(
                                  indent: 2.5,
                                  thickness: 1,
                                  color: appBackgroundColor,
                                ),
                                Text(
                                  "scrollingDirection: ${_controller.scrollingDirection.name}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const Divider(
                                  indent: 2.5,
                                  thickness: 1,
                                  color: appBackgroundColor,
                                ),
                                Text(
                                  "direction: ${_controller.direction.name}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const Divider(
                                  indent: 2.5,
                                  thickness: 1,
                                  color: appBackgroundColor,
                                ),
                                Text(
                                  "edge: ${_controller.edge.name}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const Divider(
                                  indent: 2.5,
                                  thickness: 1,
                                  color: appBackgroundColor,
                                ),
                                Text(
                                  "side: ${_controller.side.name}",
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
                                      "isRefreshEnabled: ${_controller.isRefreshEnabled}",
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          _controller.isRefreshEnabled
                                              ? Colors.red
                                              : Colors.lightGreen,
                                        ),
                                      ),
                                      child: Text(
                                        _controller.isRefreshEnabled
                                            ? "DISABLE"
                                            : "ENABLE",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () =>
                                          _controller.isRefreshEnabled
                                              ? _controller.disableRefresh()
                                              : _controller.enableRefresh(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
                ),
              ],
            ),
          ),
          builder: (
            BuildContext context,
            Widget child,
            IndicatorController controller,
          ) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Stack(
                alignment: _controller.side.isBottom
                    ? AlignmentDirectional.bottomStart
                    : AlignmentDirectional.topStart,
                children: <Widget>[
                  Container(
                    height: 100,
                    color: Colors.amber,
                    child: const Center(
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
                    margin: controller.side.isBottom
                        ? const EdgeInsets.only(bottom: 100)
                        : const EdgeInsets.only(top: 100),
                    width: double.infinity,
                    height: 50,
                    color: Colors.greenAccent,
                    child: const Center(
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
                  Transform.translate(
                    offset: Offset(
                      0.0,
                      (_controller.side.isBottom ? -100 : 100) *
                          _controller.value,
                    ),
                    child: child,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
