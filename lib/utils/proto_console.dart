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
  void refresh() {
    setState(() {
      searchResults = dataTypes[page].values.where((item) {
        return item.toString().contains(search);
      }).toList();
    });
  }

  late ErrorHandler errorHandler;
  List<dynamic> dataTypes = [
    BridgeHandler.beData,
    BridgeHandler.askData,
    BridgeHandler.attributeData
  ];
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
  int page = 0;
  bool verbose = true;
  static final stub = StreamClient(ProtoUtils.getChannel());
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
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        children: [
                          SizedBox(
                            width: 1,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3),
                              itemCount: 12,
                              shrinkWrap: true,
                              
                              itemBuilder: (context, index) {
                                ColorScheme scheme =
                                    BridgeHandler.getTheme().colorScheme;
                                List<Color> colours = [
                                  scheme.background,
                                  scheme.onBackground,
                                  scheme.error,
                                  scheme.onError,
                                  scheme.primary,
                                  scheme.onPrimary,
                                  scheme.secondary,
                                  scheme.onSecondary,
                                  scheme.surface,
                                  scheme.onSurface,
                                  scheme.tertiary,
                                  scheme.onTertiary
                                ];
                                Map<String, Color> colourMap = {
                                  "background": scheme.background,
                                  "onBackground": scheme.onBackground,
                                  "error": scheme.error,
                                  "onError": scheme.onError,
                                  "primary": scheme.primary,
                                  "onPrimary": scheme.onPrimary,
                                  "secondary": scheme.secondary,
                                  "onSecondary": scheme.onSecondary,
                                  "surface": scheme.surface,
                                  "onSurface": scheme.onSurface,
                                  "tertiary": scheme.tertiary,
                                  "onTertiary": scheme.onTertiary
                                };
                                return Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Container(
                                    
                                      color: colours[index],
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 15,),
                                          Text(colourMap.keys.elementAt(index),
                                              style: const TextStyle(
                                                  backgroundColor: Colors.white)),
                                          const Expanded(child: SizedBox(),),
                                          Center(
                                            child: Text("$index", style: const TextStyle(
                                              fontSize: 22,
                                              backgroundColor: Colors.white),),
                                          ),
                                        ],
                                      )),
                                );
                              },
                            ),
                          ),
                          const LinearProgressIndicator(),
                          const CircularProgressIndicator()
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.palette)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Radio(
                  value: 0,
                  groupValue: page,
                  onChanged: (_) {
                    setState(() {
                      page = 0;
                      refresh();
                    });
                  }),
              Radio(
                  value: 1,
                  groupValue: page,
                  onChanged: (_) {
                    setState(() {
                      page = 1;
                      refresh();
                    });
                  }),
              Radio(
                  value: 2,
                  groupValue: page,
                  onChanged: (_) {
                    setState(() {
                      page = 2;
                      refresh();
                    });
                  }),
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
                      refresh();
                    });
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                          : page == 1
                              ? makeBold(
                                  searchResults[index].question.code.toString(),
                                  search)
                              : makeBold(
                                  searchResults[index].code.toString(), search),
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
