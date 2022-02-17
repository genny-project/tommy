import "../ProjectEnv.dart";

class BridgeEnvs {
  static get bridgeUrl {
    print("${ProjectEnv.url}/api/events/init?url=${ProjectEnv.url}");
    return ProjectEnv.url + "/api/events/init?url=" + ProjectEnv.url;
  }

  static get logoutUrl {
    print("This is the realm[" + realm + "]");
    return authServerUrl +
        "/realms/" +
        realm +
        "/protocol/openid-connect/logout";
    //const url = 'https://keycloak.gada.io/auth/realms/internmatch/protocol/openid-connect/logout?client_id=internmatch&nonce=ce3e5fe3-9e2b-4f7c-9d13-9ff1d5bdd5a5&redirect_uri=https%3A%2F%2Finternmatch-test.gada.io&response_mode=query&response_type=code&state=0c940a59-bb1d-4017-9ae7-329b2d1b4836';
  }

  static get authUrl {
    authServerUrl = "https://keycloak.gada.io/auth";
    print("This is the realm $realm");
    print("This is the auth server $authServerUrl");
    return "$authServerUrl/realms/$realm/.well-known/openid-configuration";
    //return authServerUrl+"/realms/"+realm+"/protocol/openid-connect/token";
  }

  static var realm = ProjectEnv.realm;
  static var authServerUrl = "https://keycloak.gada.io/";
  static var sslRequired;
  static var resource;
  static var credentials;
  static var clientID;
  static var vertexUrl;
  static var apiUrl;
  static var url;
  static var ENV_GENNY_HOST;
  static var ENV_GENNY_INITURL;
  static var ENV_GENNY_BRIDGE_SERVICE;
  static var ENV_GENNY_BRIDGE_EVENTS;
  static var ENV_GENNY_BRIDGE_VERTEX;

  

  static bool fetchSuccess = false;
  //static bool fetchSuccess = true;

  static final Map map = {
    'realm': (val) => realm = val,
    'auth-server-url': (val) => authServerUrl = val,
    'ssl-required': (val) => sslRequired = val,
    'resource': (val) => resource = val,
    'credentials': (val) => credentials = val,
    'vertx_url': (val) => vertexUrl = val,
    'api_url': (val) => apiUrl = val,
    'url': (val) => url = val,
    'clientId': (val) => clientID = val,
    'ENV_GENNY_HOST': (val) => ENV_GENNY_HOST = val,
    'ENV_GENNY_INITURL': (val) => ENV_GENNY_INITURL = val,
    'ENV_GENNY_BRIDGE_SERVICE': (val) => ENV_GENNY_BRIDGE_SERVICE = val,
    'ENV_GENNY_BRIDGE_EVENTS': (val) => ENV_GENNY_BRIDGE_EVENTS = val,
    'ENV_GENNY_BRIDGE_VERTEX': (val) => ENV_GENNY_BRIDGE_VERTEX = val,
  };
}
