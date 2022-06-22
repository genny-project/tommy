

// ignore_for_file: prefer_interpolation_to_compose_strings

class ProjectEnv {
  static const String baseUrl = "https://lojing-dev.gada.io";
  // static const String baseUrl = "http://lojing.genny.life";
  // static const String baseUrl = "http://lojing.genny.life";
  // static const String baseUrl = "http://alyson7.genny.life";
  // static const String authServerUrl = "https://keycloak.gada.io/auth";
  static const String apiVersion = "/v7";
  static const String projectName = "InternMatch";
  
  static const String httpURL = baseUrl + apiVersion + "/api/service/sync";
  static const String devicesUrl = baseUrl + apiVersion + "/api/devices";
}
