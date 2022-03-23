import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geoff/geoff.dart';
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
  // final minio = Minio(
  //     useSSL: false,
  //     endPoint: "10.0.2.2",
  //     accessKey: dotenv.env['MINIO_ACCESS']!,
  //     secretKey: dotenv.env['MINIO_SECRET']!);
  int _counter = 0;
  List<Map<String, dynamic>> beData = [];
  List<BaseEntity> baseEntitites = [];
  List<QDataAskMessage> askMessages = [];
  late Timer timer;
  Drawer drawer = Drawer();
  final stub = StreamClient(ProtoUtils.getChannel());
  @override
  void initState() {
    super.initState();
    stub
        .connect(Item.create()
          ..token = Session.tokenResponse.accessToken!
          ..body = jsonEncode({'connect': 'connect'}))
        .listen((item) {
      _log.info("Got item $item");
      if (item.body != "{\"h\"}") {
        _log.info("Got item ${jsonDecode(item.body)['data_type']}");
        if (jsonDecode(item.body)['data_type'] == 'BaseEntity') {
          setState(() {
            JsonEncoder encoder = JsonEncoder.withIndent('  ');
            Map<String, dynamic> json = jsonDecode(item.body);
            EntityAttribute attribute = EntityAttribute.create();
            // attribute.mergeFromProto3Json(jsonDecode(item.body));
            // attribute.mergeFromJson(item.body);
            attribute.mergeFromProto3Json(
                jsonDecode(item.body)['items'][0]['baseEntityAttributes'][0]);
            // baseEntitites.add(attribute);

            // beData.add(encoder.convert(json));
          });
        } else if (jsonDecode(item.body)['data_type'] == "QBulkMessage") {
          // _log.info("QBulkMessage item ${item.body}");
          beData.add(jsonDecode(item.body));
          QBulkMessage message = QBulkMessage.create();
          message.mergeFromProto3Json(jsonDecode(item.body),
              ignoreUnknownFields: true);
          for (QMessage qmessage in message.messages) {
            for (BaseEntity baseEntity in qmessage.items) {
              setState(() {
                baseEntitites.add(baseEntity);
              });
            }
          }
        } else if (jsonDecode(item.body)['data_type'] == "Ask") {
          QDataAskMessage ask = QDataAskMessage.create();
          _log.log("Item body ${jsonDecode(item.body)}");
          ask.mergeFromProto3Json(jsonDecode(item.body));
          ask.items.forEach((ask) {
            if (ask.name == "Sidebar") {
              _log.log("Creating Drawer for sidebar");
              setState(() {
                drawer = BridgeHandler.createDrawer(ask);
              });
            }
          });
          setState(() {
            askMessages.add(ask);

            _log.log("Added ask, current length ${askMessages.length}");
          });
        }
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
      String json =
          jsonEncode({"1": Session.tokenResponse.accessToken, "2": "{\"h\"}"});
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
              .toProto3Json())

        // ..body = jsonEncode({
        //   "token": Session.tokenResponse.accessToken,
        //   "msg_type": "EVT_MSG",
        //   "event_type": "BTN_CLICK",
        //   "redirect": true,
        //   "data": {
        //     "code": "QUE_DASHBOARD_VIEW",
        //     "parentCode": "QUE_DASHBOARD_VIEW"
        //   }
        // })

        );

    // Future.delayed(Duration(seconds: 15)).then((value) {
    //   print("Getting form...");

    // });
  }

  // "2": jsonEncode({
  //               "token": Session.tokenResponse!.accessToken,
  //               "msg_type": "EVT_MSG",
  //               "event_type": "BTN_CLICK",
  //               "redirect": true,
  //               "data": {
  //                 "code": "QUE_DASHBOARD_VIEW",
  //                 "parentCode": "QUE_DASHBOARD_VIEW"
  //               }
  //             })

// {"msgType":"EVT_MSG","eventType":"AUTH_INIT","data":"{"code":"AUTH_INIT","platform":{"type":"web"},"sessionId":"27fa4a68-b8b6-44c3-9868-36af42838a20"}"}
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) => const ProtoConsole())));
              },
              icon: const Icon(Icons.graphic_eq))
        ],
        title: const Text("main page"),
      ),
      drawer: drawer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Data',
            ),
            Expanded(
              child: Container(
                height: 400,
                child: ListView.builder(
                    itemCount: askMessages.length,
                    itemBuilder: ((context, index) {
                      List<Widget> widgets = [];
                      BaseEntity be = baseEntitites[index];
                      QDataAskMessage msg = askMessages[index];
                      List<Ask> asks = msg.items;
                      List<EntityAttribute> at = be.baseEntityAttributes;

                      asks.forEach((ask) {
                        ask.childAsks.forEach((childAsk) {});
                        widgets.add(Container(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Text(ask.toString())));
                      });
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
                          baseEntitites[index].toProto3Json().toString());
                    })),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Item getForm = Item.create()
            ..token = Session.token
            ..body = jsonEncode((QMessage.create()
                  ..token = Session.token
                  ..msgType = "EVT_MSG"
                  ..eventType = "BTN_CLICK"
                  ..redirect = true
                  ..dataType = "Answer"
                  ..data = (MessageData.create()
                    ..code = "QUE_QA_INTERN_MENU"
                    ..parentCode = "QUE_ADD_ITEMS_GRP"))
                .toProto3Json());
          setState(() {
            askMessages.clear();
          });
          stub.sink(getForm);

          //{"type":"send","address":"address.inbound",
          //"headers":{"Authorization":"Bearer token here"},
          //"body":{"data":
          //{"data":{"parentCode":"QUE_ADD_ITEMS_GRP","code":"QUE_EDU_PRO_MENU"},
          //"token":"token here","msg_type":"EVT_MSG","event_type":"BTN_CLICK","redirect":true}}}
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
