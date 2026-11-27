import 'package:custom_refresh_indicator_material/custom_refresh_indicator_material.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('CustomMaterialIndicator')),
        body: CustomMaterialIndicator(
          onRefresh: () => Future<void>.delayed(const Duration(seconds: 2)),
          indicatorBuilder: (context, controller) {
            return const Icon(Icons.ac_unit, size: 30);
          },
          child: ListView.builder(
            itemCount: 30,
            itemBuilder: (context, index) {
              return ListTile(title: Text('Item ${index + 1}'));
            },
          ),
        ),
      ),
    );
  }
}
