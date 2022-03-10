import 'package:grpc/grpc.dart';


class ProtoUtils {
  static ClientChannel getChannel() {
    ClientChannel channel = ClientChannel(
      '10.0.2.2',
      port: 5154,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    return channel;
  }
}
