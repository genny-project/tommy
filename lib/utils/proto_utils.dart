// import 'package:grpc/grpc.dart';

import 'package:grpc/grpc_web.dart';
import 'package:grpc/grpc.dart';
import 'package:tommy/projectenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
class ProtoUtils {
  static dynamic getChannel() {
    dynamic channel;
    print("Grpc url ${ProjectEnv.grpcUrl} ${ProjectEnv.grpcPort}");
    if(kIsWeb) {
      print("Web client...");
      channel = GrpcWebClientChannel.xhr(
      Uri.parse("http://"
      + ProjectEnv.grpcUrl+":"+ProjectEnv.grpcPort.toString()),
      );
    } else {
      channel = ClientChannel(ProjectEnv.grpcUrl, port: ProjectEnv.grpcPort);
    }
    
    return channel;
  }
}
