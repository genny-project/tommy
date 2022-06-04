import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoff/geoff.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/messagedata.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/generated/qmessage.pb.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/utils/bridge_handler.dart';
// import 'package:tommy/utils/log.dart';
import 'package:tommy/utils/proto_console.dart';
import 'package:tommy/utils/proto_utils.dart';
import 'package:tommy/utils/template_handler.dart';
// import 'package:tommy/utils/proto_utils.dart';

class GennyViewport extends StatefulWidget {
  const GennyViewport({Key? key}) : super(key: key);
  @override
  State<GennyViewport> createState() => _GennyViewportState();
}

class _GennyViewportState extends State<GennyViewport> {
  static final Log _log = Log("Viewport");
  BridgeHandler handler = BridgeHandler(BridgeHandler.initialiseState());
  BaseEntity root = BaseEntity.create();
  List<Widget> widgets = [];
  late Timer timer;
  final _formKey = GlobalKey<FormFieldState>();
  final stub = StreamClient(ProtoUtils.getChannel());
  List<TextEditingController> controllers = [];
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
            ..token = Session.tokenResponse!.accessToken!
            ..body = jsonEncode({'connect': 'connect'}))
          .listen((item) async {
        if (item.body != "{\"h\"}") {
          handler.handleData(jsonDecode(item.body), beCallback: ((be) async {
            if (be.code == "PCM_ROOT") {
              _log.info("Found root");
              setState(() {
                root = be;
              });
            }
            setState(() {});
          }), askCallback: ((askmsg) {
            for (Ask ask in askmsg.items) {
              widgets.add(Text(
                ask.name + " " + ask.questionCode,
                style: const TextStyle(color: Colors.blue),
              ));
              if (ask.name == "Avatar") {}

              if (ask.name == "Avatar Menu") {}
            }
            setState(() {});
          }));
        }
      });

      _log.info("Connected. Attempting Auth Init");
      Item authInit = Item.create()
        ..token = Session.token!..body = jsonEncode((QMessage.create()
              ..eventType = "AUTH_INIT"
              ..msgType = "EVT_MSG"
              ..token = Session.tokenResponse!.accessToken!
              ..data = (MessageData.create()
                ..code = "AUTH_INIT"
                ..platform.addAll({"type": "web"})
                ..sessionId = Session.tokenData['jti']))
            .toProto3Json());

      // jsonEncode({
      //   "msgType": "EVT_MSG",
      //   "eventType": "AUTH_INIT",
      //   "token": Session.tokenResponse!.accessToken,
      //   "data": {
      //     "code": 'AUTH_INIT',
      //     "platform": {"type": "web"},
      //     "sessionId": Session.tokenData['jti'],
      //   }
      // });
      timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        String json = jsonEncode(
            {"1": Session.tokenResponse!.accessToken, "2": "{\"h\"}"});
        stub.heartbeat(Item.fromJson(json));
        // _log.info("Beat");
      });
      _log.info("Auth init data ${authInit.toProto3Json()}}");
      // var r = {"msgype":"EVT_MSG","eventType":"AUTH_INIT","data":{"code":"AUTH_INIT","platform":{"type":"web"},"sessionId":"2cd42df2-87f4-4122-b3a2-6170a3076bf8"}};
      // var l = {"event_type":"AUTH_INIT","msg_type":"EVT_MSG","data":{"code":"AUTH_INIT","platform":{"type":"web"},"sessionId":"2cd42df2-87f4-4122-b3a2-6170a3076bf8"}};
      stub.sink(authInit);
      _log.info("Attempting Get Dashboard View");

      //{"type":"send","address":"address.inbound","headers":{"Authorization":"Bearer suffice","msg_type":"EVT_MSG","event_type":"BTN_CLICK","redirect":true}}}
      stub.sink(Item.create()
        ..token = Session.token!..body = jsonEncode((QMessage.create()
              ..token = Session.tokenResponse!.accessToken!
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
    return root.baseEntityAttributes.isNotEmpty == true
        ? rootScaffold(root)
        : const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
    // return Scaffold(
    //   // appBar: AppBar(
    //   //   actions: [
    //   //     IconButton(
    //   //         onPressed: () {
    //   //           Navigator.of(context).push(MaterialPageRoute(
    //   //               builder: ((context) => ProtoConsole(handler))));
    //   //         },
    //   //         icon: const Icon(Icons.graphic_eq))
    //   //   ],
    //   //   title: const Text("main page"),
    //   // )
    //   appBar: getAppBar(),
    //   drawer: getDrawer(),
    //   body: Column(
    //     children: [
    //       IconButton(
    //           onPressed: () {
    //             Navigator.of(context).push(MaterialPageRoute(
    //                 builder: ((context) => ProtoConsole(handler))));
    //           },
    //           icon: const Icon(Icons.graphic_eq)),
    //       Text(handler.state.DISPLAY),
    //       Expanded(
    //         child: ListView.builder(
    //             itemCount: widgets.length,
    //             itemBuilder: ((context, index) {
    //               return widgets[index];
    //             })),
    //       )
    //     ],
    //   ),
    // );
  }

  Scaffold rootScaffold(BaseEntity root) {
    return Scaffold(
      appBar: getAppBar(),
      drawer: getDrawer(),
      body: getBody(),
    );
  }

  Widget getBody() {
    return ListView(
      children: [
        Text(BridgeHandler.findAttribute(root, 'PRI_LOC3').valueString.toString()),
        Container(
          height: 100,
          width: 100,
          child: BridgeHandler.getPcmWidget(BridgeHandler.findAttribute(root, 'PRI_LOC3'))),
        IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => ProtoConsole())));
            },
            icon: const Icon(Icons.graphic_eq)),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Flexible(
                child: ListView.builder(
                  itemCount: BridgeHandler.askData.values.where((element) => element.processId != "no-idq",).length,
                  // shrinkWrap: true,
                  itemBuilder: ((context, index) {
                    Ask returnAsk = BridgeHandler.askData.values.where((element) => element.processId != "no-idq",).elementAt(index);
                    controllers.add(TextEditingController());
                    return TemplateHandler.getField(returnAsk, context);
                  }),
                ),
              ),
            ],
          ),
        ),
        // Text(be.baseEntityAttributes.toString()),
      ],
    );
  }

  Widget getDrawer() {
    BaseEntity? root = BridgeHandler.findByCode("PCM_ROOT");
    BaseEntity? be = BridgeHandler.findByCode(
        BridgeHandler.findAttribute(root, "PRI_LOC2").valueString);

    EntityAttribute attribute = be.baseEntityAttributes.firstWhere(
        (attribute) => attribute.attributeCode == "PRI_QUESTION_CODE");
    return BridgeHandler.getPcmWidget(BridgeHandler.findAttribute(root, "PRI_LOC2"));
  }

  AppBar getAppBar() {
    List<Widget> actions = [];
    Widget title = SizedBox();
    BaseEntity? root = BridgeHandler.findByCode("PCM_ROOT");
    BaseEntity? be = BridgeHandler.findByCode(
        BridgeHandler.findAttribute(root, "PRI_LOC1").valueString);
    be.baseEntityAttributes.sort(((a, b) => a.weight.compareTo(b.weight)));
    for (var attribute in be.baseEntityAttributes) {
      Ask? ask = BridgeHandler.askData[attribute.valueString];
      if (attribute.valueString.startsWith("PCM_")) {
        actions.add(BridgeHandler.getPcmWidget(attribute));
      } else {
        if (ask != null) {
          if (ask.childAsks.isNotEmpty) {
            List<PopupMenuEntry<String>> buttons = [];
            for (Ask ask in ask.childAsks) {
              buttons.add(PopupMenuItem(
                  value: ask.questionCode, child: Text(ask.name)));
            }
            actions.add(Container(
                height: 20,
                width: 50,
                child: PopupMenuButton<String>(
                    onSelected: (String result) {
                      setState(() {
                        _log.info("Handling event - $result");
                        BridgeHandler.evt(result);
                      });
                    },
                    itemBuilder: (BuildContext context) => buttons)));
          } else {
            title = IconButton(
              onPressed: () {
                BridgeHandler.evt(attribute.valueString);
              },
              icon: SvgPicture.network(
                "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                    (ask.question.icon),
                height: 30,
                width: 30,
              ),
            );
          }
        } else {
          // actions.add(
          //         IconButton(
          //           onPressed: (){
          //             ScaffoldMessenger.of(context).clearSnackBars();
          //             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The ASK could not be loaded. ${attribute.valueString}")));
          //           },
          //           icon: Icon(Icons.error, color: Colors.red,)));
        }
      }
    }
    return AppBar(
      title: title,
      centerTitle: false,
      actions: actions,
    );
  }
}
