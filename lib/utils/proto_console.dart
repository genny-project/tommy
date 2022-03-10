import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/models/session.dart';
import 'package:tommy/projectstyle.dart';
import 'package:tommy/utils/log.dart';
import 'package:tommy/utils/proto_utils.dart';

class ProtoConsole extends StatefulWidget {
  const ProtoConsole({Key? key}) : super(key: key);

  @override
  _ProtoConsoleState createState() => _ProtoConsoleState();
}

class _ProtoConsoleState extends State<ProtoConsole> {
  static final Log _log = Log("ProtoConsoleState");

  final myController = TextEditingController();
  List data = [];

  late Timer timer;

  final Duration heartbeatDuration =const Duration(seconds:5);

  late ErrorHandler handler;

  @override
  void initState() {
    super.initState();
    super.setState(() {
      handler = (object, stacktrace) {
        GrpcError error = object as GrpcError;
        _log.error("Error code ${error.code}");
        _log.error(error.toString());
        _log.error(stacktrace);
        timer.cancel();
      };
    });
  }

  final stub = StreamClient(ProtoUtils.getChannel());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Proto Test"),
        backgroundColor: ProjectStyle.projectColor,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Column(children: [
        Text(Session.tokenData['jti'].toString()),
        TextButton(
          child: const Text("Connect"),
          onPressed: () async {
            _log.info("Connecting");

            stub
                .connect(Item.fromJson(jsonEncode({
              "1": Session.tokenResponse!.accessToken,
              "2": jsonEncode({"connect": "connect"})
            })))
                .listen((value) {
              if (value.body != "{\"h\"}") {
                _log.info("Listen value ${value.body}");
              }
            }).onError(handler);
            setState(() {
              timer = Timer.periodic(heartbeatDuration, (timer) {
                String json = jsonEncode(
                    {"1": Session.tokenResponse!.accessToken, "2": "{\"h\"}"});
                stub.heartbeat(Item.fromJson(json));
              });
            });
          },
        ),
        TextButton(
          child: const Text("Auth Init"),
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
          child: const Text("Dashboard Button"),
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
    );
  }
}
