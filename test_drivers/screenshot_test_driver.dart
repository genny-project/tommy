
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (reportData) async {
  
    if (reportData != null) {

      if (reportData.containsKey("screenshots")) {

        List<Map<String,dynamic>> screenshots = (reportData['screenshots'] as List<dynamic>).cast();

        for (Map<String,dynamic> screenshot in screenshots) {

          String name = screenshot['screenshotName'] as String;
          List<int> bytes = (screenshot['bytes'] as List<dynamic>).cast();

          if (!name.endsWith(".png")) {
            name = "$name.png";
          }

          await (await File('screenshots/$name').create(recursive: true)).writeAsBytes(bytes);

        }

      }

    }

  }
);