import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoff/geoff.dart';
import 'package:http/http.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tommy/genny_viewport.dart';
import 'package:tommy/main.dart' as app;
import 'package:tommy/utils/bridge_env.dart';

//Potential solution to solve
//import 'package:flutter/services.dart';

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

      await tester.pump(new Duration(seconds: 5));

      // Wait for a certain amount of seconds
      await tester.pump(new Duration(seconds: 5));
    });

    //testWidgets('authentication testing', (tester) async {
    //  await AppAuthHelper.login(
    //      authServerUrl: BridgeEnv.ENV_KEYCLOAK_REDIRECTURI,
    //      realm: BridgeEnv.realm,
    //      clientId: BridgeEnv.clientID,
    //      redirectUrl: "life.genny.tommy.appauth://oauth/login_success/");

    //  await tester.pumpAndSettle();

    // });
  });
}
