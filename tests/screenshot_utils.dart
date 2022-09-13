import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';

Future<void> screenshot(String name, IntegrationTestWidgetsFlutterBinding binding, {double? pixelRatio,Duration delay = const Duration(milliseconds: 20)}) async {

  Screenshot screenshot = (find.byType(Screenshot).evaluate().single.widget as Screenshot);

  await screenshot.controller.capture(pixelRatio: pixelRatio, delay: delay).then((bytes) {
    if (bytes != null) {

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['screenshots'] ??= <dynamic>[];

      final Map<String, dynamic> data = {"screenshotName":name,"bytes":bytes.map((e) => e).toList()};

      assert(data.containsKey('bytes'));

      (binding.reportData!['screenshots']! as List<dynamic>).add(data);

    }
  
  });

  return;

}