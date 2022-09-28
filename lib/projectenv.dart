// ignore_for_file: prefer_interpolation_to_compose_strings

class ProjectEnv {
  static String baseUrl = const String.fromEnvironment('BASE_URL');
  static bool devMode = baseUrl.isEmpty ? true : false;
  static const List<String> urls = ["https://lojing-dev.gada.io", "https://internmatch-dev.gada.io"];

  static String grpcUrl = const bool.hasEnvironment("GRPC_URL") ? const String.fromEnvironment("GRPC_URL") : baseUrl.replaceFirst("https://", "");
  static int grpcPort = const int.fromEnvironment("GRPC_PORT");
  static const String apiVersion = "/v7";
  static const String projectName = "InternMatch";
  static String httpURL = baseUrl + apiVersion + "/api/service/sync";
  static String devicesUrl = baseUrl + apiVersion + "/api/devices";
}
