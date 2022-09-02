import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tommy/genny_viewport.dart';
import 'package:tommy/main.dart' as app;
import 'package:tommy/templates/tpl_dashboard.dart';
import 'package:tommy/templates/tpl_sidebar.dart';
import 'package:tommy/generated/baseentity.pb.dart';

void main() {
  group('App Test', () {
    // Add the IntegrationTestWidgetsFlutterBinding and .ensureInitialized
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('full app test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check to see if the TOMMY text is there
      //expect(find.text('TOMMY'), findsOneWidget);

      // Create finder for login
      final loginButton = find.byType(OutlinedButton).first;

      tester.printToConsole('Tap on the login button');
      // Tapping the login button
      await tester.tap(loginButton);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Wait for a certain amount of seconds
      await tester.pump(const Duration(seconds: 5));

      //Expect to find 4 widgets
      //expect(find.byType(ListTile), findsNWidgets(4));
      //tester.printToConsole('Found 4 listtile widgets');

      int count = 2;
      while (count < 4) {
        final ScaffoldState state = tester.firstState(find.byType(Scaffold));
        state.openDrawer();
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 5));
        final listtile = find.byType(ListTile).at(count);
        await tester.tap(listtile);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 5));
        count++;
      }
    });
  });
}
