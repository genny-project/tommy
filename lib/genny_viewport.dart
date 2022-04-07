import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoff/geoff.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/baseentity.pbjson.dart';
import 'package:tommy/generated/messagedata.pb.dart';
import 'package:tommy/generated/qbulkmessage.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/generated/qmessage.pb.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/utils/bridge_handler.dart';
// import 'package:tommy/utils/log.dart';
import 'package:tommy/utils/proto_console.dart';
import 'package:minio/minio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:tommy/utils/proto_utils.dart';

class GennyViewport extends StatefulWidget {
  const GennyViewport({Key? key}) : super(key: key);
  @override
  State<GennyViewport> createState() => _GennyViewportState();
}

class _GennyViewportState extends State<GennyViewport> {
  static final Log _log = Log("Viewport");
  BridgeHandler handler = BridgeHandler(BridgeHandler.initialiseState());

  List<Map<String, dynamic>> beData = [];

  List<Widget> widgets = [];
  late Timer timer;

  Drawer drawer = Drawer();
  final stub = StreamClient(ProtoUtils.getChannel());
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((pr) {
      setState(() {
        prefs = pr;
      });
      stub
          .connect(Item.create()
            ..token = Session.tokenResponse.accessToken!
            ..body = jsonEncode({'connect': 'connect'}))
          .listen((item) async {
        if (item.body.contains("PCM")) {
          _log.info("Got PCM ${item.body}");
          Clipboard.setData(ClipboardData(text: item.body));
        }
        if (item.body != "{\"h\"}") {
          _log.info("Got item ${jsonDecode(item.body)['data_type']}");
          if (jsonDecode(item.body)['data_type'] == null) {
            _log.info("Item null " + item.body);
            widgets.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text(
                jsonDecode(item.body).toString(),
                style: TextStyle(color: Colors.red),
              ),
            ));
          }

          handler.handleData(jsonDecode(item.body), beCallback: ((be) async {
            // widgets.add(Text(be.name));
            List<Widget> cardChildren = [];
            if (be.code == "PCM_SIDEBAR") {
              _log.info("Got Sidebar");
              setState(() {
                drawer = handler.createDrawer(be);
              });
            }
            for (EntityAttribute attribute in be.baseEntityAttributes) {
              if (attribute.attributeCode.startsWith("PRI_")) {
                // widgets.add(TextFormField(
                //   decoration:
                //       InputDecoration(labelText: attribute.attribute.name),
                //   initialValue: attribute.valueString,
                // ));
              } else {
                // cardChildren.add(Text(attribute.attributeName + " " + attribute.valueString));
              }
              // widgets.add(Card(child: Column(
              //   children: cardChildren,
              // ),));
            }
            setState(() {});
          }), askCallback: ((askmsg) {
            for (Ask ask in askmsg.items) {
              widgets.add(Text(
                ask.questionCode,
                style: const TextStyle(color: Colors.blue),
              ));
              if (ask.name == "Avatar") {}

              if (ask.name == "Avatar Menu") {}
            }
            setState(() {});
          }));
          // if (jsonDecode(item.body)['data_type'] == 'BaseEntity') {
          //   JsonEncoder encoder = JsonEncoder.withIndent('  ');
          //   Map<String, dynamic> json = jsonDecode(item.body);
          //   BaseEntity baseEntity = BaseEntity.create();
          //   EntityAttribute attribute = EntityAttribute.create();
          //   // attribute.mergeFromProto3Json(jsonDecode(item.body));
          //   // attribute.mergeFromJson(item.body);
          //   attribute.mergeFromProto3Json(
          //       jsonDecode(item.body)['items'][0]['baseEntityAttributes'][0]);
          //   baseEntity.mergeFromProto3Json(json, ignoreUnknownFields: true);
          //   _log.info("BaseEntity $baseEntity");
          //   // baseEntitites.add(attribute);
          //   await prefs.setString(
          //       baseEntity.code, baseEntity.writeToBuffer().toString());

          //   // beData.add(encoder.convert(json));
          // } else if (jsonDecode(item.body)['data_type'] == "QBulkMessage") {
          //   // _log.info("QBulkMessage item ${item.body}");
          //   beData.add(jsonDecode(item.body));
          //   QBulkMessage message = QBulkMessage.create();
          //   message.mergeFromProto3Json(jsonDecode(item.body),
          //       ignoreUnknownFields: true);
          //   handler.qb.add(message);
          //   for (QMessage qmessage in message.messages) {
          //     for (BaseEntity baseEntity in qmessage.items) {
          //       setState(() {
          //         handler.be.add(baseEntity);
          //       });
          //     }
          //   }
          // } else if (jsonDecode(item.body)['data_type'] == "Ask") {
          //   QDataAskMessage ask = QDataAskMessage.create();
          //   ask.mergeFromProto3Json(jsonDecode(item.body));
          //   ask.items.forEach((ask) {
          //     if (ask.name == "Sidebar") {
          //       _log.log("Creating Drawer for sidebar");
          //       setState(() {
          //         drawer = BridgeHandler.createDrawer(ask, setState(() {}));
          //       });
          //     }
          //   });
          //   setState(() {
          //     handler.ask.add(ask);
          //     _log.log("Added ask, current length ${handler.ask.length}");
          //   });
          // }
        }
      });

      _log.info("Connected. Attempting Auth Init");
      Item authInit = Item.create()
        ..token = Session.token
        ..body = jsonEncode((QMessage.create()
              ..eventType = "AUTH_INIT"
              ..msgType = "EVT_MSG"
              ..token = Session.tokenResponse.accessToken!
              ..data = (MessageData.create()
                ..code = "AUTH_INIT"
                ..platform.addAll({"type": "web"})
                ..sessionId = Session.tokenData['jti']))
            .toProto3Json());

      // jsonEncode({
      //   "msgType": "EVT_MSG",
      //   "eventType": "AUTH_INIT",
      //   "token": Session.tokenResponse.accessToken,
      //   "data": {
      //     "code": 'AUTH_INIT',
      //     "platform": {"type": "web"},
      //     "sessionId": Session.tokenData['jti'],
      //   }
      // });
      timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        String json = jsonEncode(
            {"1": Session.tokenResponse.accessToken, "2": "{\"h\"}"});
        stub.heartbeat(Item.fromJson(json));
        // _log.info("Beat");
      });
      Item other = Item.fromJson(jsonEncode({
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
      }));
      _log.info("Auth init data ${authInit.toProto3Json()}}");
      _log.info("Othe init data $other");
      _log.info(
          "Identical ${(authInit.writeToJson().length)}  ${other.writeToJson().length}");
      // var r = {"msgype":"EVT_MSG","eventType":"AUTH_INIT","data":{"code":"AUTH_INIT","platform":{"type":"web"},"sessionId":"2cd42df2-87f4-4122-b3a2-6170a3076bf8"}};
      // var l = {"event_type":"AUTH_INIT","msg_type":"EVT_MSG","data":{"code":"AUTH_INIT","platform":{"type":"web"},"sessionId":"2cd42df2-87f4-4122-b3a2-6170a3076bf8"}};
      stub.sink(authInit);
      _log.info("Attempting Get Dashboard View");

      //{"type":"send","address":"address.inbound","headers":{"Authorization":"Bearer suffice","msg_type":"EVT_MSG","event_type":"BTN_CLICK","redirect":true}}}
      stub.sink(Item.create()
        ..token = Session.token
        ..body = jsonEncode((QMessage.create()
              ..token = Session.tokenResponse.accessToken!
              ..msgType = "EVT_MSG"
              ..eventType = "BTN_CLICK"
              ..redirect = true
              ..data = (MessageData.create()
                ..code = "QUE_DASHBOARD_VIEW"
                ..parentCode = "QUE_DASHBOARD_VIEW"))
            .toProto3Json()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     IconButton(
      //         onPressed: () {
      //           Navigator.of(context).push(MaterialPageRoute(
      //               builder: ((context) => ProtoConsole(handler))));
      //         },
      //         icon: const Icon(Icons.graphic_eq))
      //   ],
      //   title: const Text("main page"),
      // )
      appBar: getAppBar(),
      drawer: getDrawer(),
      body: Column(
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) => ProtoConsole(handler))));
              },
              icon: const Icon(Icons.graphic_eq)),
          Text(handler.state.DISPLAY),
          Expanded(
            child: ListView.builder(
                itemCount: widgets.length,
                itemBuilder: ((context, index) {
                  return widgets[index];
                })),
          )
        ],
      ),
    );
  }

  Drawer getDrawer() {
    return Drawer(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: handler.be
                .firstWhere((be) => be.code == "PCM_SIDEBAR", orElse: () {
                  return BaseEntity.create();
                })
                .baseEntityAttributes
                .length,
            itemBuilder: (context, index) {
              BaseEntity be =
                  handler.be.firstWhere((be) => be.code == "PCM_SIDEBAR");
              List<Widget> buttons = [];

              // be.baseEntityAttributes
              be.baseEntityAttributes.sort(((a, b) {
                return a.weight.compareTo(b.weight);
              }));
              EntityAttribute attribute = be.baseEntityAttributes[index];

              Ask? ask = handler.askData[attribute.valueString];
              if (ask != null) {
                if (attribute.valueString.endsWith("_GRP")) {
                  for (Ask ask in ask.childAsks) {
                    buttons.add(ListTile(
                      onTap: () {
                        handler.evt(ask.questionCode);
                        Navigator.pop(context);
                      },
                      title: Text(ask.name),
                    ));
                  }
                }
                return attribute.valueString.endsWith("_GRP")
                    ? ExpansionTile(
                        leading: Container(
                          width: 50,
                          child: SvgPicture.network(
                            "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                                (ask.question.icon),
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: Text(ask.name),
                        children: buttons,
                      )
                    : ListTile(
                        // style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        leading: Container(
                          width: 50,
                          child: SvgPicture.network(
                            "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                                ask.question.icon,
                            height: 30,
                            width: 30,
                          ),
                        ),
                        onTap: () {
                          handler.evt(ask.questionCode);
                          Navigator.pop(context);
                        },
                        title: Text(ask.name));
              }
              return SizedBox();
            }));
  }

  AppBar getAppBar() {
    List<Widget> actions = [];
    Widget title = SizedBox();
    BaseEntity? be =
        handler.be.firstWhere((be) => be.code == "PCM_HEADER", orElse: (() {
      return BaseEntity.create();
    }));

    be.baseEntityAttributes.sort(((a, b) => a.weight.compareTo(b.weight)));
    be.baseEntityAttributes.forEach((attribute) {
      Ask? ask = handler.askData[attribute.valueString];
      if (ask != null) {
        if (attribute.valueString.endsWith("_GRP")) {
          List<PopupMenuEntry<String>> buttons = [];
          if (ask != null) {
            for (Ask ask in ask.childAsks) {
              buttons.add(PopupMenuItem(
                  value: ask.questionCode, child: Text(ask.name)));
            }
          }
          actions.add(Container(
              height: 20,
              width: 50,
              child: PopupMenuButton<String>(
                  onSelected: (String result) {
                    setState(() {
                      _log.info(result);
                      handler.evt(result);
                    });
                  },
                  itemBuilder: (BuildContext context) => buttons)));
        } else {
          title = IconButton(
            onPressed: () {
              handler.evt(attribute.valueString);
            },
            icon: SvgPicture.network(
              "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                  (ask.question.icon),
              height: 30,
              width: 30,
            ),
          );
        }
      }
    });
    return AppBar(
      title: title,
      centerTitle: true,
      actions: actions,
    );
  }
}
