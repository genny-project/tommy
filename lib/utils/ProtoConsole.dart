import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/models/Session.dart';
import 'package:tommy/utils/ProtoUtils.dart';
// import 'package:grpc/service_api.dart';
import '../../ProjectEnv.dart';

class ProtoConsole extends StatefulWidget {
  ProtoConsole();

  @override
  _ProtoConsoleState createState() => _ProtoConsoleState();
}

class _ProtoConsoleState extends State<ProtoConsole> {
  final myController = TextEditingController();
  List data = [];

  late Timer timer;

  late ErrorHandler handler;

  @override
  void initState() {
    super.initState();
    super.setState(() {
      handler = (object, stacktrace) {
        GrpcError error = object as GrpcError;
        print("Error code ${error.code}");
        print(error.toString());
        print(stacktrace);
        timer.cancel();
      };
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final stub = StreamClient(ProtoUtils.getChannel());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Proto Test"),
        backgroundColor: Color(ProjectEnv.projectColor),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        child: Column(children: [
          Text(Session.tokenData['jti'].toString()),
          TextButton(
            child: Text("Connect"),
            onPressed: () async {
              print("Connecting");

              stub
                  .connect(Item.fromJson(jsonEncode({
                "1": Session.tokenResponse!.accessToken,
                "2": jsonEncode({"connect": "connect"})
              })))
                  .listen((value) {
                if (value.body != "{\"h\"}") {
                  print("Listen value ${value.body}");
                }
              }).onError(handler);
              setState(() {
                timer = Timer.periodic(Duration(seconds: 5), (timer) {
                  String json = jsonEncode(
                      {"1": Session.tokenResponse!.accessToken, "2": "{\"h\"}"});
                  stub.heartbeat(Item.fromJson(json));
                  print("Beat");
                });
              });
            },
          ),
          TextButton(
            child: Text("Auth Init"),
            onPressed: () {
              stub.sink(Item.fromJson(jsonEncode({
                "1": Session.tokenResponse!.accessToken,
                "2": jsonEncode({
                  "event_type": "AUTH_INIT",
                  "msg_type": "EVT_MSG",
                  "token": Session.tokenResponse!.accessToken,
                  "data": {
                    "code": "AUTH_INIT",
                    "platform": {"type": "web"},
                    "sessionId": Session.tokenData['jti'],
                  }
                })
              })));
            },
          ),
          TextButton(
            child: Text("Dashboard Button"),
            onPressed: () async {
              stub.sink(Item.fromJson(jsonEncode({
                "1": Session.tokenResponse!.accessToken,
                "2": jsonEncode({
                  "token": Session.tokenResponse!.accessToken,
                  "msg_type": "EVT_MSG",
                  "event_type": "BTN_CLICK",
                  "redirect": true,
                  "data": {
                    "code": "QUE_DASHBOARD_VIEW",
                    "parentCode": "QUE_DASHBOARD_VIEW"
                  }
                })
              })));
            },
          )
        ]),
      ),
    );
  }
}
