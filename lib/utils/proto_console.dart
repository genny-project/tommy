import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoff/utils/networking/auth/session.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qbulkmessage.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/projectstyle.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/proto_utils.dart';

class ProtoConsole extends StatefulWidget {
  BridgeHandler handler;
  ProtoConsole(this.handler, {Key? key}) : super(key: key);

  @override
  _ProtoConsoleState createState() => _ProtoConsoleState();
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
                      "1": Session.tokenResponse.accessToken,
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
                          "1": Session.tokenResponse.accessToken,
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
                      "1": Session.tokenResponse.accessToken,
                      "2": jsonEncode({
                        "event_type": "AUTH_INIT",
                        "msg_type": "EVT_MSG",
                        "token": Session.tokenResponse.accessToken,
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
                  child: const Text("Dashboard Button"),
                  onPressed: () async {
                    stub.sink(Item.fromJson(jsonEncode({
                      "1": Session.tokenResponse.accessToken,
                      "2": jsonEncode({
                        "token": Session.tokenResponse.accessToken,
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
                  icon: Icon(Icons.copy),
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
                          ? searchResults = widget.handler.be.where((item) {
                              return item.toString().contains(search);
                            }).toList()
                          : searchResults = widget.handler.askData.values.where((item) {
                              return item.toString().contains(search);
                            }).toList();
                    });
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !askSwitch ? Text("ASK") : Text("BE"),
                  Switch(
                    
                      value: askSwitch,
                      onChanged: (v) {
                        setState(() {
                          askSwitch = v;
                          askSwitch
                              ? searchResults = widget.handler.beData.values.where((item) {
                                  return item.toString().contains(search);
                                }).toList()
                              : searchResults = widget.handler.askData.values.where((item) {
                                  return item.toString().contains(search);
                                }).toList();
                        });
                      }),
                ],
              )
            ],
          ),
          Expanded(
            child: Container(
              height: 400,
              child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: ((context, index) {
                    List<Widget> widgets = [];
                    BaseEntity be = widget.handler.be[index];
                    // QDataAskMessage msg = widget.handler.ask[index];
                    // List<Ask> asks = msg.items;
                    List<EntityAttribute> at = be.baseEntityAttributes;
                    widgets.add(Column(children: [
                      IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: searchResults[index].toString()))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Item Copied")));
                            });
                          },
                          icon: Icon(Icons.copy)),
                          makeBold(searchResults[index].toString(), search)
                      // Text(searchResults[index]
                      //     .toString()
                      //     .replaceAll(search, search.toUpperCase()))
                    ]));
                    // asks.forEach((ask) {
                    //   ask.childAsks.forEach((childAsk) {});
                    //   widgets.add(Container(
                    //       padding: EdgeInsets.symmetric(vertical: 30),
                    //       child: Text(ask.toString())));
                    // });
                    // widgets.add(Text(
                    //   be.code.toString(),
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ));
                    // widgets.add(Text(be.name));
                    // if (be.code.startsWith("PER_")) {
                    //   at.forEach((attribute) {
                    //     List<Widget> children = [];
                    //     if (attribute.attributeName == "ImageUrl") {
                    //       children.add(Text(
                    //         attribute.attributeName,
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ));

                    //       children.add(Image.network(
                    //         "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                    //             attribute.valueString,
                    //         width: MediaQuery.of(context).size.width,
                    //       ));
                    //     } else {
                    //       children.add(Text(
                    //         attribute.attributeCode,
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ));
                    //       children
                    //           .add(Text(attribute.valueString.toString()));
                    //     }
                    //     widgets.add(Column(children: children));
                    //     // children.add(Text(attribute.attributeName.toString()));
                    //     // children.add(Text(attribute.valueString));
                    //   });
                    //   // widgets.add(Column(children: [
                    //   //   Text(at.toString())
                    //   // ],));
                    // }
                    for (EntityAttribute attribute in at) {
                      // widgets.add(Text(attribute.toString()));
                      // if (attribute.attributeCode == "COL_PRI_IMAGE_URL") {
                      //   if (be.toProto3Json().toString().contains("http")) {
                      //     widgets.add(Text(be.toProto3Json().toString()));
                      //   }
                      //   // widgets.add(Text(be.toProto3Json().toString()));
                      //   widgets.add(
                      //     Image.network(attribute.valueString),
                      //   );
                      // }
                    }
                    return Container(
                      child: Column(children: widgets),
                    );
                    return Text(
                        widget.handler.be[index].toProto3Json().toString());
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
      textWidgets.add(TextSpan(text: string, style: const TextStyle(color: Colors.black)));
      if (i != contentSplit.length-1) {
        textWidgets.add(TextSpan(text: search, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red)));
      }
      i++;
    }
    return RichText(text: TextSpan(
      children: textWidgets));
    
  }
}
