import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoff/geoff.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/projectstyle.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/proto_utils.dart';

class ProtoConsole extends StatefulWidget {
  const ProtoConsole({Key? key}) : super(key: key);

  @override
  State<ProtoConsole> createState() => _ProtoConsoleState();
}

class _ProtoConsoleState extends State<ProtoConsole> {
  static final Log _log = Log("ProtoConsoleState");

  final myController = TextEditingController();
  List data = [];

  late Timer timer;

  final Duration heartbeatDuration = const Duration(seconds: 5);

  late ErrorHandler errorHandler;

  @override
  void initState() {
    super.initState();
    super.setState(() {
      errorHandler = (object, stacktrace) {
        GrpcError error = object as GrpcError;
        _log.error("Error code ${error.code}");
        _log.error(error.toString());
        _log.error(stacktrace);
        timer.cancel();
      };
    });
  }

  List<dynamic> searchResults = [];
  String search = "";
  bool askSwitch = false;
  bool verbose = true;
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
      body: Column(
        children: [
          Text(Session.tokenData['jti'].toString()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
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
                    }).onError(errorHandler);
                    setState(() {
                      timer = Timer.periodic(heartbeatDuration, (timer) {
                        String json = jsonEncode({
                          "1": Session.tokenResponse!.accessToken,
                          "2": "{\"h\"}"
                        });
                        stub.heartbeat(Item.fromJson(json));
                      });
                    });
                  },
                ),
              ),
              Expanded(
                child: TextButton(
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
              ),
              Expanded(
                child: TextButton(
                  child: const Text("processquestions"),
                  onPressed: () async {
                    stub.sink(Item.fromJson(jsonEncode({
                      "1": Session.tokenResponse!.accessToken,
                      "2": jsonEncode({
                        "token": Session.tokenResponse!.accessToken,
                        "msg_type": "EVT_MSG",
                        "event_type": "BTN_CLICK",
                        "redirect": true,
                        "data": {
                          "code": "processquestions",
                          "parentCode": "processquestions"
                          // "questionCode":
                          // "targetCode":
                          // "pcmCode":
                          // "usrTokenString":
                          // "target code pcm code user target string"
                        }
                      })
                    })));
                  },
                ),
              ),
            ],
          ),
          Text(
            'Data - Count ${searchResults.length}',
          ),
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: (() {
                    Clipboard.setData(
                        ClipboardData(text: searchResults.toString()));
                  })),
              Flexible(
                child: TextField(
                  onChanged: (search) {
                    this.search = search;
                    setState(() {
                      askSwitch
                          ? searchResults =
                              BridgeHandler.beData.values.where((item) {
                              return item.toString().contains(search);
                            }).toList()
                          : searchResults =
                              BridgeHandler.askData.values.where((item) {
                              return item.toString().contains(search);
                            }).toList();
                    });
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !askSwitch ? const Text("ASK") : const Text("BE"),
                  Switch(
                      value: askSwitch,
                      onChanged: (v) {
                        setState(() {
                          askSwitch = v;
                          askSwitch
                              ? searchResults =
                                  BridgeHandler.beData.values.where((item) {
                                  return item.toString().contains(search);
                                }).toList()
                              : searchResults =
                                  BridgeHandler.askData.values.where((item) {
                                  return item.toString().contains(search);
                                }).toList();
                        });
                      }),
                  Switch(
                      value: verbose,
                      onChanged: (v) {
                        BridgeHandler.getProject();
                        setState(() {
                          verbose = v;
                        });
                      })
                ],
              )
            ],
          ),
          Expanded(
            child: SizedBox(
              height: 400,
              child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: ((context, index) {
                    List<Widget> widgets = [];
                    widgets.add(Column(children: [
                      IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: searchResults[index].toString()))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Item Copied")));
                            });
                          },
                          icon: const Icon(Icons.copy)),
                      Text(searchResults[index].name.toString()),
                      verbose
                          ? makeBold(searchResults[index].toString(), search)
                          : askSwitch
                              ? makeBold(
                                  searchResults[index].code.toString(), search)
                              : makeBold(
                                  searchResults[index].question.code.toString(),
                                  search),
                    ]));
                    return Column(children: widgets);
                  })),
            ),
          ),
        ],
      ),
    );
  }

  RichText makeBold(String content, String search) {
    List<String> contentSplit = content.split(search);
    List<TextSpan> textWidgets = [];
    int i = 0;
    for (String string in contentSplit) {
      textWidgets.add(
          TextSpan(text: string, style: const TextStyle(color: Colors.black)));
      if (i != contentSplit.length - 1) {
        textWidgets.add(TextSpan(
            text: search,
            style: const TextStyle(
                fontWeight: FontWeight.w900, color: Colors.red)));
      }
      i++;
    }
    return RichText(text: TextSpan(children: textWidgets));
  }
}
