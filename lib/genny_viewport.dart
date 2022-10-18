import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geoff/geoff.dart';
import 'package:grpc/grpc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/messagedata.pb.dart';
import 'package:tommy/generated/qmessage.pb.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/main.dart';
import 'package:tommy/projectenv.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/proto_console.dart';
import 'package:tommy/utils/proto_utils.dart';
import 'package:tommy/utils/template_handler.dart';

class GennyViewport extends StatefulWidget {
  const GennyViewport({Key? key}) : super(key: key);
  @override
  State<GennyViewport> createState() => _GennyViewportState();
}

class _GennyViewportState extends State<GennyViewport>
    with WidgetsBindingObserver {
  static final Log _log = Log("Viewport");
  BridgeHandler handler = BridgeHandler();
  late final ScreenshotController screenshotController;
  BaseEntity root = BaseEntity.create();
  FocusNode focus = FocusNode();
  late TemplateHandler templateHandler;
  late Timer timer;
  late SharedPreferences prefs;
  StreamSubscription getSubscription() {
    // ScaffoldMessenger.of(context).clearMaterialBanners();
    return BridgeHandler.client
      .connect(Item.create()
        ..token = Session.tokenResponse!.accessToken!
        ..body = jsonEncode({'connect': 'connect'}))
      .asBroadcastStream()
      .listen(listener, onError: onError);}

  late StreamSubscription sub = getSubscription();
  late Function onError = (e) {
    e as GrpcError;
    _log.error("ENCOUNTERED GRPC ERROR ${e.code} $e");

    switch (e.code) {
      case 2:
        {
          //UNKNOWN - Unknown error [Most commonly an HTTP2 error]
          _log.warning("Connection lost - HTTP/2 Error. Retrying...");
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              content: ListTile(title: Text("Re-establishing connection"), subtitle: Text("2 - ${e.message}"), trailing: CircularProgressIndicator(),),));
          sub = getSubscription();
          break;
        }
      case 10:
        {
          //ABORTED
          //on ios, when the app has been closed for a period of ~20 seconds, the grpc connection gets aborted
          //however, the app does not receive this message until it is re-opened
          //hence the need to reset the listener by creating a new connection

          //presently it is unknown whether this occurs on android, or any other platform
          //if it does, that would denote that the timeout span is longer than the 20 seconds on ios
          _log.warning(
              "Connection has been aborted. Creating new connection...");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              content: ListTile(title: Text("Re-establishing connection"), subtitle: Text("10 - ${e.message}"), trailing: CircularProgressIndicator(),),));
          //restart the connection
          sub = getSubscription();
          break;
        }
      case 14:
        {
          //UNAVAILABLE
          // e.details!.first
          print(RetryInfo.getDefault());
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              content: ListTile(title: Text("Re-establishing connection"), subtitle: Text("14 - ${e.message}"), trailing: CircularProgressIndicator(),),));
              actions: [CircularProgressIndicator()];
          // defaultBackoffStrategy(lastBackoff)
          sub = getSubscription();
          break;
        }
    }
  };
  late void Function(Item) listener = (item) {
    if (item.body != '{"h"}') {
      setState(() {
        BridgeHandler.message.value = item;
      });
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
        for (Ask item in askmsg.items) {
          if (!BridgeHandler.askData.containsValue(item)) {
            setState(() {});
          }
        }
      }));
    }
  };
  @override
  void dispose() {
    handler = BridgeHandler();
    timer.cancel();
    sub.cancel();
    super.dispose();
    focus.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("Got new state - $state");
    //this function isnt used for an awful lot anymore, since
    //the aborted connection issue is now handled in the connect function
    //but pausing the subscription makes the app more performant in the background
    //so its worth keeping
    switch (state) {
      case AppLifecycleState.paused:
        {
          sub.pause();
          break;
        }
      case AppLifecycleState.resumed:
        {
          sub.resume();
          break;
        }
      default:
        {
          break;
        }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    screenshotController = ScreenshotController();
    templateHandler = TemplateHandler();
    super.initState();
    SharedPreferences.getInstance().then((pr) {
      setState(() {
        prefs = pr;
      });
      sub.resume();
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

        BridgeHandler.client.heartbeat(Item.fromJson(json));
      });
      _log.info("Auth init data ${authInit.toProto3Json()}}");
      //###############
      //homogenising (if thats the right word. probably is.) the clients
      //i realised that i was creating multiple and that that would be a Bad Idea
      //so now its easier to track down and brutally eviscerate any bugs that may (read: will) appear
      //###############
      BridgeHandler.client.sink(authInit);
      _log.info("Attempting Get Dashboard View");
      BridgeHandler.client.sink(Item.create()
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
    return Screenshot(
      controller: screenshotController,
      child: root.baseEntityAttributes.isNotEmpty == true
          ? rootScaffold(root)
          : Scaffold(
              body: Center(
                child: InkWell(
                  onLongPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProtoConsole(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      TextButton(
                        onPressed: () {
                          AppAuthHelper.logout();
                          navigatorKey.currentState?.pop();
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    return ListView(children: [root.PRI_LOC(3).getPcmWidget()]);
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
