// ignore_for_file: prefer_interpolation_to_compose_strings

class ProjectEnv {
  static const String baseUrl = "https://lojing-dev.gada.io";
  // static const String baseUrl = "https://internmatch-dev.gada.io";
  // static const String baseUrl = "http://10.0.2.2";

  static const String grpcUrl = "10.0.2.2";
  static const int grpcPort = 5154;

  static const String apiVersion = "/v7";
  static const String projectName = "InternMatch";
  static const String httpURL = baseUrl + apiVersion + "/api/service/sync";
  static const String devicesUrl = baseUrl + apiVersion + "/api/devices";
}
