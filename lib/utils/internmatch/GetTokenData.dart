import '../../ProjectEnv.dart';
import 'dart:convert';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import 'AppAuthHelper.dart';

Map<String, dynamic> tokenData;
Future<void> getToken() async {
//final String token = AppAuthHelper.token;
  String token;
  if (ProjectEnv.token != null) {
    token = ProjectEnv.token;
  } else {
    token = AppAuthHelper.token;
  }
  final parts = token.split('.');
  final payload = parts[1];
  final String decoded = B64urlEncRfc7515.decodeUtf8(payload);
  tokenData = json.decode(decoded);
}
