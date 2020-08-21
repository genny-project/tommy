import 'package:flutter_appauth/flutter_appauth.dart';
import '../../models/BridgeEnv.dart';
import '../../models/SessionData.dart';
import './ApiHelper.dart';
import './GetTokenData.dart';

import '../../ProjectEnv.dart';

class AppAuthHelper {
  static FlutterAppAuth appAuth = new FlutterAppAuth();
  static var _redirectUrl = "io.demo-app.appauth://oauth/login_success";
  static var refreshExpireIn;
  static var token;
  static var unixTime = (new DateTime.now()).millisecondsSinceEpoch;
  static authTokenResponse() async {
    var result;

    if (ProjectEnv.token == null) {
      result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(BridgeEnvs.clientID, _redirectUrl,
            // discoveryUrl: '${BridgeEnvs.url}/realms/${BridgeEnvs.realm}/account'
            discoveryUrl: '${BridgeEnvs.authUrl}',
            clientSecret: '${BridgeEnvs.credentials['secret']}'),
      );
      print("Result from Key Cloak :: ${result.accessToken}");
      print(
          "Autorization Additional Parameters  :: ${result.authorizationAdditionalParameters}");
      print("Additional parameters :: ${result.tokenAdditionalParameters}");
      refreshExpireIn = result.tokenAdditionalParameters['refresh_expires_in'];
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
      await getToken();
    } else {
      token = ProjectEnv.token;
      await getToken();
    }
    return result;
  }

  static logOut() async {
    var header = {
      "Authorization": "Bearer ${Session.tokenResponse.accessToken}",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    var body = {
      "client_id": BridgeEnvs.clientID,
      "client_secret": BridgeEnvs.credentials['secret'],
      "refresh_token": Session.tokenResponse.refreshToken,
      "session_state": Session
          .tokenResponse.authorizationAdditionalParameters["session_state"]
    };

    keycloakApiHelperClass.makePostRequest(BridgeEnvs.logoutUrl,
        headers: header, body: body);
  }
}
