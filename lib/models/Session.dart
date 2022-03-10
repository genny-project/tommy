import 'package:flutter_appauth/flutter_appauth.dart';

class Session {
  static AuthorizationTokenResponse? tokenResponse;
  static SessionState _sessionState = SessionState.loggedOut;

  static Map<String,dynamic> tokenData = {};

  static void cleanSessionData() {
    tokenResponse = null;
  }

  static bool get isLoggedIn {
    return (_sessionState == SessionState.loggedIn);
  }

  static bool get isExpired {
    return (_sessionState == SessionState.expired);
  }

  static bool get isLoggedOut {
    return (_sessionState == SessionState.loggedOut);
  }

   static SessionState get sessionState {
    return _sessionState;
  }

  static set sessionState(SessionState value) {
    if (value != SessionState.loggedIn) {
      cleanSessionData();
    }
    _sessionState = value;
  }
}

enum SessionState { loggedIn, loggedOut, expired }
