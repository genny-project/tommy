import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:tommy/models/session.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:tommy/models/bridge_env.dart';
import 'package:tommy/utils/log.dart';

class AppAuthHelper {

  static final Log _log = Log("AppAuthHelper");

  static FlutterAppAuth appAuth = FlutterAppAuth();
  static const String _redirectUrl =  "io.demo-app.appauth://oauth/login_success/";


  static authTokenResponse() async {
    AuthorizationTokenResponse? result;
    //_log.info("BridgeEnvs ${BridgeEnv.map}");
    _log.info("Auth ${BridgeEnv.authUrl}");
    _log.info("Url ${BridgeEnv.bridgeUrl}");
    _log.info("Redirect url $_redirectUrl");

    result = await appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
        "alyson", _redirectUrl,
        discoveryUrl: BridgeEnv.authUrl));

    if (result != null) {
      Session.tokenResponse = result;
      Session.token = result.accessToken;
      getTokenData(Session.token!);
    } else {
      _log.error("Got null from app auth!");
      //TODO: throw an exception
    }
    
    return result;
  }

  static logOut(tokenResponse) async {
    Map<String, String> header = {
      "Authorization": "Bearer ${Session.token}",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    Map<String, dynamic> body = {
      "client_id": BridgeEnv.clientID,
      "client_secret": BridgeEnv.credentials['secret'],
      "refresh_token": Session.tokenResponse?.refreshToken,
      "session_state": Session
          .tokenResponse?.authorizationAdditionalParameters?["session_state"]
    };

    http.post(BridgeEnv.logoutUrl, headers: header, body: body);
  }
}

void getTokenData(String token) {
  final parts = token.split('.');
  final payload = parts[1];
  final String decoded = B64urlEncRfc7515.decodeUtf8(payload);
  Session.tokenData = json.decode(decoded);
}
