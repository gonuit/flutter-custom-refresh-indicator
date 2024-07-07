import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:example/widgets/example_app_bar.dart';
import 'package:example/widgets/example_list.dart';
import 'package:flutter/material.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final _controller = IndicatorController(refreshEnabled: true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const ExampleAppBar(),
      body: SafeArea(
        child: CustomRefreshIndicator(
          trigger: IndicatorTrigger.bothEdges,
          durations: const RefreshIndicatorDurations(
            finalizeDuration: Duration(seconds: 1),
            settleDuration: Duration(seconds: 1),
            cancelDuration: Duration(seconds: 1),
          ),
          leadingScrollIndicatorVisible: false,
          trailingScrollIndicatorVisible: false,
          offsetToArmed: 100.0,
          controller: _controller,
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 4)
              ],
            ),
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
                        return Align(
                          alignment: _controller.side.isNone
                              ? Alignment.center
                              : _controller.side.isBottom
                                  ? Alignment.bottomCenter
                                  : Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: AppCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: Center(
                                        child: Text(
                                          "IndicatorController",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Table(
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      border: TableBorder(
                                        horizontalInside: BorderSide(
                                          width: 1,
                                          color: theme.dividerColor,
                                        ),
                                      ),
                                      children: [
                                        TableRow(
                                          children: [
                                            const Text("value:"),
                                            Text(_controller.value
                                                .toStringAsFixed(2)),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            const Text("state:"),
                                            Text(_controller.state.name),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            const Text("scrollingDirection:"),
                                            Text(_controller
                                                .scrollingDirection.name),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            const Text("direction:"),
                                            Text(_controller.direction.name),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            const Text("edge:"),
                                            Text('${_controller.edge?.name}'),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            const Text("side:"),
                                            Text(_controller.side.name),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            const Text("dragDetails.delta:"),
                                            Text(
                                                '${_controller.dragDetails?.delta}'),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            const Text(
                                                "dragDetails.localPosition:"),
                                            Text(
                                                '${_controller.dragDetails?.localPosition}'),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            const Text("isRefreshEnabled:"),
                                            Text(_controller.isRefreshEnabled
                                                .toString()),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Switch(
                                        value: _controller.isRefreshEnabled,
                                        activeColor: Colors.lightGreen,
                                        onChanged: (isEnabled) => isEnabled
                                            ? _controller.enableRefresh()
                                            : _controller.disableRefresh(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
