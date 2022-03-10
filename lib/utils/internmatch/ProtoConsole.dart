import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grpc/grpc_connection_interface.dart';
// import 'package:grpc/service_api.dart';
import 'package:internmatch/generated/helloworld.pbgrpc.dart';
import 'package:internmatch/generated/stream.pbgrpc.dart';
import 'package:internmatch/models/SessionData.dart';
import 'package:internmatch/utils/internmatch/GetTokenData.dart';
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
  ErrorHandler handler = (object, stacktrace) {
    GrpcError error = object as GrpcError;
    print("Error code ${error.code}");
    print(error.toString());
    print(stacktrace);
    // timer.cancel();
  };

  @override
  void initState() {
    super.initState();
    super.setState(() {});
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final stub = StreamClient(ProtoUtils.getChannel());
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
          Text(tokenData['jti'].toString()),
          TextButton(
            child: Text("Connect"),
            onPressed: () async {
              print("Connecting");
            
              stub
                  .connect(
                      // Item.fromJson(jsonEncode({
                      //   "1": Session.tokenResponse.accessToken,
                      //   "2": jsonEncode({
                      //     "type": "register",
                      //     "address":
                      //         tokenData['jti'],
                      //     "headers": {}
                      //   })
                      // })),
                      Item.fromJson(jsonEncode({
                "1": Session.tokenResponse.accessToken,
                "2": jsonEncode({
                  "event_type": "AUTH_INIT",
                  "msg_type": "EVT_MSG",
                  "token": Session.tokenResponse.accessToken,
                  "data": {
                    "code": "AUTH_INIT",
                    "platform": {"type": "web"},
                    "sessionId": tokenData['jti'],
                  }
                })
              })))
                  .listen((value) {

                    if (value.body != "{\"h\"}") {
                      print("Listen value ${value.body}");
                    }

                
              }).onError(handler);
              Timer.periodic(Duration(seconds: 5), (timer) {
                String json = jsonEncode(
                    {"1": Session.tokenResponse.accessToken, "2": "{\"h\"}"});
                stub.heartbeat(Item.fromJson(json));
                print("Beat");
              });
              // stub.sink(Item.fromJson(jsonEncode({
              //   "1": Session.tokenResponse.accessToken,
              //   "2": jsonEncode({
              //     "type": "send",
              //     "address": "address.inbound",
              //     "headers": {
              //       "Authorization":
              //           "Bearer ${Session.tokenResponse.accessToken}"
              //     },
              //     "body": {
              //       "data": {
              //         "data": {
              //           "code": "QUE_DASHBOARD_VIEW",
              //           "parentCode": "QUE_DASHBOARD_VIEW"
              //         },
              //         "token": Session.tokenResponse.accessToken,
              //         "msg_type": "EVT_MSG",
              //         "event_type": "BTN_CLICK",
              //         "redirect": true
              //       }
              //     }
              //   })
              // })));
            },
          ),
          TextButton(
            child: Text("Sink"),
            onPressed: () {
              stub.sink(Item.fromJson(jsonEncode({
                "1": Session.tokenResponse.accessToken,
                "2": jsonEncode({
                  "event_type": "AUTH_INIT",
                  "msg_type": "EVT_MSG",
                  "token": Session.tokenResponse.accessToken,
                  "data": {
                    "code": "AUTH_INIT",
                    "platform": {"type": "web"},
                    "sessionId": tokenData['jti'],
                  }
                })
              })));
            },
          ),
          TextButton(
            child: Text("Say Hello"),
            onPressed: () async {
              ClientChannel channel = ProtoUtils.getChannel();

              final stub = GreeterClient(channel);

              final name = 'world';

              try {
                var response = await stub.sayHello(HelloRequest()..name = name);
                print('Greeter client received: ${response.message}');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Client received: ${response.writeToJson()}')));
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
