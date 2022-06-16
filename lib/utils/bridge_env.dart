

import 'package:geoff/utils/system/log.dart';
import 'package:tommy/projectenv.dart';

class BridgeEnv {

  static final Log _log = Log("BridgeEnvs");

  static get bridgeUrl {
    _log.info("${ProjectEnv.baseUrl}/api/events/init?url=${ProjectEnv.baseUrl}");
    return ProjectEnv.baseUrl + "/api/events/init?url=" + ProjectEnv.baseUrl;
  }

  static get logoutUrl {
    _log.info("This is the realm[$clientID]");
    return "$ENV_KEYCLOAK_REDIRECTURI/realms/$clientID/protocol/openid-connect/logout";
  }

  static get authUrl {
    ENV_KEYCLOAK_REDIRECTURI = "https://keycloak.gada.io/auth";
    _log.info("This is the realm $clientID");
    _log.info("This is the auth server $ENV_KEYCLOAK_REDIRECTURI");
    return "$ENV_KEYCLOAK_REDIRECTURI/realms/$clientID/.well-known/openid-configuration";
  }

  static late String realm;
  static late String sslRequired;
  static late String resource;
  static late Map<String, dynamic> credentials;
  static late String clientID;
  static late String vertexUrl;
  static late String apiUrl;
  static late String url;

  static late String ENV_KEYCLOAK_REDIRECTURI;
  // ignore: non_constant_identifier_names
  static late String ENV_GENNY_HOST;
  // ignore: non_constant_identifier_names
  static late String ENV_GENNY_INITURL;
    // ignore: non_constant_identifier_names
  static late String ENV_GENNY_BRIDGE_SERVICE;
    // ignore: non_constant_identifier_names
  static late String ENV_GENNY_BRIDGE_EVENTS;
    // ignore: non_constant_identifier_names
  static late String ENV_GENNY_BRIDGE_VERTEX;
    // ignore: non_constant_identifier_names
  static late String ENV_MEDIA_PROXY_URL;

  static bool fetchSuccess = false;

  /// This rather strange thing is basically just a setter.
  /// Only use this for conversion from JSON Objects,
  /// Pass in val, and it will set the value, assuming it is in the map
  static Map<String, void Function(dynamic)> map = {
    'realm': (val) => realm = val,
    'ssl-required': (val) => sslRequired = val,
    'resource': (val) => resource = val,
    'credentials': (val) => credentials = val,
    'vertx_url': (val) => vertexUrl = val,
    'api_url': (val) => apiUrl = val,
    'url': (val) => url = val,
    'clientId': (val) => clientID = val,
    'ENV_KEYCLOAK_REDIRECTURI': (val) => ENV_KEYCLOAK_REDIRECTURI = val,
    'ENV_GENNY_HOST': (val) => ENV_GENNY_HOST = val,
    'ENV_GENNY_INITURL': (val) => ENV_GENNY_INITURL = val,
    'ENV_GENNY_BRIDGE_SERVICE': (val) => ENV_GENNY_BRIDGE_SERVICE = val,
    'ENV_GENNY_BRIDGE_EVENTS': (val) => ENV_GENNY_BRIDGE_EVENTS = val,
    'ENV_GENNY_BRIDGE_VERTEX': (val) => ENV_GENNY_BRIDGE_VERTEX = val,
    'ENV_MEDIA_PROXY_URL': (val) => ENV_MEDIA_PROXY_URL = val,
  };
}
