import 'package:grpc/grpc.dart';
import 'package:tommy/projectenv.dart';

class ProtoUtils {
  static ClientChannel getChannel() {
    ClientChannel channel = ClientChannel(
      ProjectEnv.grpcUrl,
      port: ProjectEnv.grpcPort,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
      );
    return channel;
  }
}
