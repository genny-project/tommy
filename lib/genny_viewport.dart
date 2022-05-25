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
            ..token = Session.tokenResponse.accessToken!
            ..body = jsonEncode({'connect': 'connect'}))
          .listen((item) async {
        if (item.body != "{\"h\"}") {
          print("Got message ${item.body}");
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
      _log.info("Auth init data ${authInit.toProto3Json()}}");
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
    BaseEntity be = BridgeHandler.findByCode("PCM_INTERN_PROFILE_DETAIL_VIEW");
    // Ask ask = BridgeHandler.askData['QUE_INTERN_GRP']!;
    return ListView(
      children: [
        IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => ProtoConsole(handler))));
            },
            icon: const Icon(Icons.graphic_eq)),
        Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Flexible(
                child: ListView.builder(
                  itemCount: BridgeHandler.askData.values.length,
                  // shrinkWrap: true,
                  itemBuilder: ((context, index) {
                    Ask returnAsk = BridgeHandler.askData.values.elementAt(index);
                    controllers.add(TextEditingController());
                    return TemplateHandler.getField(returnAsk);
                    return TextField(
                      controller: controllers[index],
                      onEditingComplete: () {
                        print("Value ${controllers[index]}");
                        Ask returnAsk = BridgeHandler.askData.values.elementAt(index);
                        // ask.processId = "4e580190-43f7-4842-9b0f-4080734f5d6f";
                        Map<String, dynamic> data = {
                          "code": "processquestions",
                          "parentCode": "processquestions",
                          "items": [
                            {
                              "askId": returnAsk.id.toInt(),
                              "processId":returnAsk.processId,
                              "attributeCode": returnAsk.attributeCode,
                              "sourceCode": returnAsk.sourceCode,
                              "targetCode": returnAsk.targetCode,
                              "code": returnAsk.questionCode,
                              "identifier": returnAsk.questionCode,
                              "weight": 1,
                              "value": "ask.childAsks[index]",
                              "inferred": false
                            }
                          ],
                          "token": Session.tokenResponse.accessToken!,
                          "msg_type": "DATA_MSG",
                          "event_type": false,
                          "redirect": false,
                          "data_type": "Answer"
                        };
                        // MayRest.userToken = Session.tokenResponse.accessToken;
                        // MayRest.get("http://alyson2.genny.life:7580/processquestions/" + returnAsk.processId).then((value) => print(value.body));
                        // stub.sink(Item.fromJson(jsonEncode({
                        //   "1": Session.tokenResponse.accessToken,
                        //   "2": jsonEncode({
                        //     "items": [
                        //       {
                        //         "askId": returnAsk.id.toInt(),
                        //         "processId":
                        //             "4e580190-43f7-4842-9b0f-4080734f5d6f",
                        //         "attributeCode": returnAsk.attributeCode,
                        //         "sourceCode": returnAsk.sourceCode,
                        //         "targetCode": returnAsk.targetCode,
                        //         "code": returnAsk.questionCode,
                        //         "identifier": returnAsk.questionCode,
                        //         "weight": 1,
                        //         "value": controllers[index].text,
                        //         "inferred": false,
                        //         "questionCode": returnAsk.questionCode,
                        //         "pcmCode": BridgeHandler.be.first.code
                        //       }
                        //     ],
                        //     "token": Session.tokenResponse.accessToken,
                        //     "msg_type": "DATA_MSG",
                        //     "event_type": false,
                        //     "redirect": false,
                        //     "data_type": "Answer",
                        //     // "data": data,
                        //   })
                        // })));
                        print("Return ask $returnAsk");
                        print("PCMCODE " + returnAsk.question.attribute.code);
                        Item answer = Item.create()
                          ..token = Session.token
                          ..body = jsonEncode({
                            "event_type": false,
                            "msg_type": "DATA_MSG",
                            "token": Session.tokenResponse.accessToken!,
                            "items": [
                              {
                                "questionCode": returnAsk.questionCode,
                                "sourceCode": returnAsk.sourceCode,
                                "targetCode": returnAsk.targetCode,
                                "askId": returnAsk.id.toInt(),
                                "pcmCode": returnAsk.question.attribute.code,
                                "attributeCode": returnAsk.question.attributeCode,
                                "processId":returnAsk.processId,
                                // "attributeCode": returnAsk.attributeCode,
                                // "code": "QUE_SUBMIT",
                                // "identifier": "QUE_SUBMIT",
                                // "weight": 1,
                                "value": controllers[index].text,
                                // "inferred": false
                              }
                            ]
                          });

                        print("Loggg $answer");
                        stub.sink(answer);
                        // stub.sink(Item.fromJson(jsonEncode({
                        //   "1": Session.tokenResponse.accessToken,
                        //   "2": jsonEncode({
                        //     "items": [
                        //       {
                        //         "askId": returnAsk.id.toInt(),
                        //         "processId":
                        //             "4e580190-43f7-4842-9b0f-4080734f5d6f",
                        //         "attributeCode": returnAsk.attributeCode,
                        //         "sourceCode": returnAsk.sourceCode,
                        //         "targetCode": returnAsk.targetCode,
                        //         "code": "QUE_SUBMIT",
                        //         "identifier": "QUE_SUBMIT",
                        //         "weight": 1,
                        //         "value": controllers[index].text,
                        //         "inferred": false
                        //       }
                        //     ],
                        //     "data": {
                        //       "code": "QUE_SUBMIT",
                        //       "platform": {"type": "web"},
                        //       "sessionId": Session.tokenData['jti'],
                        //     },
                        //     "code": "QUE_SUBMIT",
                        //     "token": Session.tokenResponse.accessToken,
                        //     "msg_type": "DATA_MSG",
                        //     "event_type": "QUE_SUBMIT",
                        //     "redirect": false,
                        //     "data_type": "Answer",
                        //   })
                        // })));
                      },
                      decoration: InputDecoration(
                          hintText: index.toString() + " " + BridgeHandler.askData.values.elementAt(index).name + " " + BridgeHandler.askData.values.elementAt(index).question.attribute.dataType.component.toString(),
                    ));
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

  Scaffold rrootScaffold(BaseEntity root) {
    return Scaffold(
        appBar: getAppBar(),
        drawer: getDrawer(),
        body: Column(
          children: [
            TextFormField(
              key: _formKey,
              initialValue: "Test",
              validator: handler.createValidator(BridgeHandler.findAttribute(
                  BridgeHandler.findByCode("PCM_TEST1"), "PRI_NAME")),
              onChanged: (text) {
                _formKey.currentState!.validate();
              },
            ),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => ProtoConsole(handler))));
                },
                icon: const Icon(Icons.graphic_eq)),
            Column(
              children: widgets,
            ),
            Flexible(
              child: ListView.builder(
                  itemCount: handler.beData.length,
                  itemBuilder: ((context, index) {
                    return Text((handler.beData.values.toList()
                          ..sort((((BaseEntity a, BaseEntity b) {
                            return a.index.compareTo(b.index);
                          }))))[index]
                        .name
                        .toString());
                  })),
            ),
            Text(root.baseEntityAttributes
                .singleWhere(
                    (attribute) => attribute.valueString == "PCM_DASHBOARD",
                    orElse: () => EntityAttribute.create())
                .toString())
          ],
        ));
  }

  Drawer getDrawer() {
    BaseEntity? root = BridgeHandler.findByCode("PCM_ROOT");
    BaseEntity? be = BridgeHandler.findByCode(
        BridgeHandler.findAttribute(root, "PRI_LOC2").valueString);

    EntityAttribute attribute = be.baseEntityAttributes.firstWhere(
        (attribute) => attribute.attributeCode == "PRI_QUESTION_CODE");
    return Drawer(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: BridgeHandler
                .askData[attribute.valueString]?.question.childQuestions.length,
            // itemCount: 5,
            itemBuilder: (context, index) {
              List<QuestionQuestion>? questions = BridgeHandler
                  .askData[attribute.valueString]?.question.childQuestions;
              List<Widget> buttons = [];
              questions!.sort(((a, b) {
                return a.weight.compareTo(b.weight);
              }));
              // EntityAttribute attribute = be.baseEntityAttributes[index];
              _log.log(
                  "Child questions ${BridgeHandler.askData[attribute.valueString]?.question.childQuestions.length}");
              _log.log("Getting ask with attribute ${attribute.valueString}");
              Ask? ask = BridgeHandler.askData[questions[index].pk.targetCode];
              if (ask != null) {
                // if (ask.childAsks.isNotEmpty) {

                for (Ask ask in ask.childAsks) {
                  buttons.add(ListTile(
                    onTap: () {
                      BridgeHandler.evt(ask.questionCode);
                      Navigator.pop(context);
                    },
                    title: Text(ask.name),
                  ));
                }
                if (ask.question.attribute.dataType.dttCode != "DTT_EVENT") {
                  return Text(
                      "Not event - ${ask.name} ${ask.question.attribute.dataType.dttCode}");
                }
                return ask.childAsks.isNotEmpty
                    ? ExpansionTile(
                        leading: Container(
                          width: 50,
                          child: SvgPicture.network(
                            "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                                (ask.question.icon),
                            height: 30,
                            width: 30,
                            placeholderBuilder: (context) {
                              return Center(
                                child: Container(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator()),
                              );
                            },
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
                            placeholderBuilder: (context) {
                              return Center(
                                child: Container(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator()),
                              );
                            },
                          ),
                        ),
                        onTap: () {
                          BridgeHandler.evt(ask.questionCode);
                          Navigator.pop(context);
                        },
                        title: Text(ask.name + " " + ask.attributeCode));
              }
              return attribute.valueString.startsWith("QUE")
                  ? ListTile(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("The ASK could not be loaded.")));
                      },
                      leading: Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      title: Text(attribute.valueString),
                    )
                  : SizedBox();
            }));
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
        actions.add(handler.getPcmWidget(attribute));
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
                        _log.info(result);
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
