import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geoff/geoff.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/messagedata.pb.dart';
import 'package:tommy/generated/qmessage.pb.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/proto_console.dart';
import 'package:tommy/utils/proto_utils.dart';
import 'package:tommy/utils/template_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class GennyViewport extends StatefulWidget {
  const GennyViewport({Key? key}) : super(key: key);
  @override
  State<GennyViewport> createState() => _GennyViewportState();
}

class _GennyViewportState extends State<GennyViewport> {
  static final Log _log = Log("Viewport");
  BridgeHandler handler = BridgeHandler(BridgeHandler.initialiseState());
  BaseEntity root = BaseEntity.create();
  FocusNode focus = FocusNode();
  late TemplateHandler templateHandler;
  late Timer timer;
  final stub = StreamClient(ProtoUtils.getChannel());
  late SharedPreferences prefs;

  @override
  void dispose() {
    super.dispose();
    focus.dispose();
  }

  @override
  void initState() {
    templateHandler = TemplateHandler();
    super.initState();
    SharedPreferences.getInstance().then((pr) {
      setState(() {
        prefs = pr;
      });

      BridgeHandler.stream.listen((item) async {
        if (item.body != "{\"h\"}") {
          BridgeHandler.message.value = item;
          handler.handleData(jsonDecode(item.body), beCallback: ((be) async {
            setState(() {
              if (be.code == "PCM_ROOT") {
                _log.info("Found root");
                setState(() {
                  root = be;
                });
              }
            });
          }), askCallback: ((askmsg) {
            // setState(() {});
          }));
        }
      });

      _log.info("Connected. Attempting Auth Init");
      Item authInit = Item.create()
        ..token = Session.token!
        ..body = jsonEncode((QMessage.create()
              ..eventType = "AUTH_INIT"
              ..msgType = "EVT_MSG"
              ..token = Session.tokenResponse!.accessToken!
              ..data = (MessageData.create()
                ..code = "AUTH_INIT"
                ..platform.addAll({"type": "web"})
                ..sessionId = Session.tokenData['jti']))
            .toProto3Json());
      timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        String json = jsonEncode(
            {"1": Session.tokenResponse!.accessToken, "2": "{\"h\"}"});
        stub.heartbeat(Item.fromJson(json));
      });
      _log.info("Auth init data ${authInit.toProto3Json()}}");
      stub.sink(authInit);
      _log.info("Attempting Get Dashboard View");
      stub.sink(Item.create()
        ..token = Session.token!
        ..body = jsonEncode((QMessage.create()
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
        : Scaffold(
            body: Center(
                child: InkWell(
                    onLongPress: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ProtoConsole()));
                    },
                    child: const CircularProgressIndicator())),
          );
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
        IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ProtoConsole()));
            },
            icon: const Icon(Icons.graphic_eq)),
        root.findAttribute('PRI_LOC3').getPcmWidget(),
      ],
    );
  }

  Widget getDrawer() {
    BaseEntity? root = BridgeHandler.findByCode("PCM_ROOT");
    return root.findAttribute("PRI_LOC2").getPcmWidget();
  }

  PreferredSizeWidget getAppBar() {
    BaseEntity? root = BridgeHandler.findByCode("PCM_ROOT");
    return PreferredSize(
        preferredSize: AppBar().preferredSize,
        child: root.findAttribute("PRI_LOC1").getPcmWidget());
  }
}
