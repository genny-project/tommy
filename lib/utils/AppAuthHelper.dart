import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:tommy/models/Session.dart';
import '../../models/BridgeEnv.dart';
// import '../../models/SessionData.dart';
// import './ApiHelper.dart';
// import './GetTokenData.dart';
  import '../../ProjectEnv.dart';
import 'dart:convert';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:http/http.dart' as http;
import '../../ProjectEnv.dart';

class AppAuthHelper {
  static FlutterAppAuth appAuth = new FlutterAppAuth();
  static var _redirectUrl = "io.demo-app.appauth://oauth/login_success/";
  static var refreshExpireIn;
  static var token;
  static var unixTime = (new DateTime.now()).millisecondsSinceEpoch;
  static authTokenResponse() async {
    AuthorizationTokenResponse result;
    if (ProjectEnv.token == null) {
      print("BridgeEnvs ${BridgeEnvs.map}");
      print("Auth ${BridgeEnvs.authUrl}");
      print("Url ${BridgeEnvs.bridgeUrl}");
      print("Redirect url $_redirectUrl");
      // result = await appAuth.token(TokenRequest("alyson", _redirectUrl, discoveryUrl: BridgeEnvs.authUrl));
      result = (await appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest("alyson", _redirectUrl, discoveryUrl: BridgeEnvs.authUrl)))!;
      // result = await appAuth.authorizeAndExchangeCode(
      //   AuthorizationTokenRequest(BridgeEnvs.clientID, _redirectUrl,
      //       // discoveryUrl: '${BridgeEnvs.url}/realms/${BridgeEnvs.realm}/account'
      //       discoveryUrl: '${BridgeEnvs.authUrl}',
      //       clientSecret: '${BridgeEnvs.credentials['secret']}'
      //       ),
      // );
      print("Result from Key Cloak :: ${result.accessToken}");
      print(
          "Autorization Additional Parameters  :: ${result.authorizationAdditionalParameters}");
      print("Additional parameters :: ${result.tokenAdditionalParameters}");
      refreshExpireIn = result.tokenAdditionalParameters!['refresh_expires_in'];
      /* Receiving new token from Key Cloak if Refresh Token expires */
      print("Refresh Token Expires In :: $refreshExpireIn");
      print("unixtime 1.5 $unixTime");
      print("unixTime 2: ${(new DateTime.now()).millisecondsSinceEpoch}");
      // while (unixTime + 2000 < (new DateTime.now()).millisecondsSinceEpoch) {
      //   print("Fetching New Access Token...");
      //   unixTime = (new DateTime.now()).millisecondsSinceEpoch;
      //   authTokenResponse();
      // }
      token = result.accessToken;
      await getToken(token);
    } else {
      result = Session.tokenResponse!;
      token = ProjectEnv.token;
      await getToken(token);
    }
    return result;
  }

  static logOut(tokenResponse) async {
    var header = {
      "Authorization": "Bearer ${ProjectEnv.token}",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    var body = {
      "client_id": BridgeEnvs.clientID,
      "client_secret": BridgeEnvs.credentials['secret'],
      "refresh_token": Session.tokenResponse?.refreshToken,
      "session_state": Session.tokenResponse?.authorizationAdditionalParameters?["session_state"]
    };

    http.post(BridgeEnvs.logoutUrl,
        headers: header, body: body);
    

  }



}

// 
Future<void> getToken(String token) async {
//final String token = AppAuthHelper.token;
  // String token;
  if (ProjectEnv.token != null) {
    token = ProjectEnv.token;
  } else {
    token = AppAuthHelper.token;
  }
  final parts = token.split('.');
  final payload = parts[1];
  final String decoded = B64urlEncRfc7515.decodeUtf8(payload);
  Session.tokenData = json.decode(decoded);
  // ProjectEnv.tokenData = json.decode(decoded);
}