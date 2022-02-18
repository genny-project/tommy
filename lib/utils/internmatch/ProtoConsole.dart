import 'package:flutter/material.dart';
import 'package:grpc/service_api.dart';
import 'package:internmatch/generated/helloworld.pbgrpc.dart';
import 'package:internmatch/utils/internmatch/ProtoUtils.dart';
import '../../ProjectEnv.dart';

class ProtoConsole extends StatefulWidget {
  ProtoConsole();

  @override
  _ProtoConsoleState createState() => _ProtoConsoleState();
}

class _ProtoConsoleState extends State<ProtoConsole> {
  final myController = TextEditingController();
  List data = [];
  @override
  void initState() {
    super.initState();
    super.setState(() {});
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: new AppBar(
            centerTitle: true,
            title: Text("Proto Test"),
            backgroundColor: Color(ProjectEnv.projectColor),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
          ),
          body: new Container(
            child: Column(children: [
              TextButton(
                child: Text("Say Hello"),
                onPressed: () async {
                  ClientChannel channel = ProtoUtils.getChannel();
                  final stub = GreeterClient(channel);

                  final name = 'world';

                  try {
                    var response =
                        await stub.sayHello(HelloRequest()..name = name);
                    print('Greeter client received: ${response.message}');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Client received: ${response.writeToJson()}')));
                    // response = await stub.sayHelloAgain(HelloRequest()..name = name);
                  } catch (e) {
                    print('Caught error: $e');
                  }
                  await channel.shutdown();
                },
              )
            ]),
          ),
        );
  }
}
