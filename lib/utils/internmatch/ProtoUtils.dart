import 'package:grpc/grpc.dart';
import 'package:internmatch/generated/helloworld.pbgrpc.dart';

class ProtoUtils {
  static ClientChannel getChannel() {
    ClientChannel channel = new ClientChannel(
      '10.0.2.2',
      port: 9090,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    return channel;
  }
}
