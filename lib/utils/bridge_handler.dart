import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geoff/geoff.dart';
import 'package:minio/models.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/cmdpayload.pb.dart';
import 'package:tommy/generated/messagedata.pb.dart';
import 'package:tommy/generated/qbulkmessage.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/generated/qmessage.pb.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/models/state.dart';
import 'package:tommy/projectenv.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BridgeHandler {
  BridgeHandler(this.state);
  AppState state;
  final stub = StreamClient(ProtoUtils.getChannel());
  final Log _log = Log("BridgeHandler");
  Map<String, BaseEntity> beData = {};
  Map<String, Ask> askData = {};
  List<BaseEntity> be = [];
  List<QBulkMessage> qb = [];
  // List<QDataAskMessage> ask = [];

  static AppState initialiseState() {
    return AppState(
    DISPLAY: 'DASHBOARD',
     DRAWER: 'NONE',
  DIALOG :'NONE',
  TOAST:null,
  DASHBOARD_COUNTS:null,
  NOTES:'',
  DUPLICATE_EMAILS:'',
  lastSentMessage:{'time': '', 'data': { 'data': { 'code': 'QUE_DASHBOARD_VIEW' } } },
  lastReceivedMessage:{},
  highlightedQuestion:'');
  // ..bufferDropdownOptions = []
  }
  dynamic getType(EntityAttribute attribute) {
    String classType = attribute.attribute.dataType.className.split('.').last;
    switch (classType) {
      case "String":
        {
          return attribute.valueString;
        }
      case "Integer":
        {
          return attribute.valueInteger;
        }
      case "Boolean":
        {
          return attribute.valueBoolean;
        }
    }

    return;
  }

  void evt(String code) {
    stub.sink(Item.create()
      ..token = Session.token
      ..body = jsonEncode((QMessage.create()
            ..token = Session.tokenResponse.accessToken!
            ..msgType = "EVT_MSG"
            ..eventType = "BTN_CLICK"
            ..redirect = true
            ..data = (MessageData.create()
              ..code = code
              ..parentCode = code))
          .toProto3Json()));
  }

  void handleData(Map<String, dynamic> data,
      {required Function(QDataAskMessage ask) askCallback,
      required Function(BaseEntity be) beCallback}) {
    if (data['msg_type'] == "CMD_MSG") {
      CmdPayload payload = CmdPayload.create();
      payload.mergeFromProto3Json(data, ignoreUnknownFields: true);
      _log.info("CMD PAYLOAD ${payload.cmdType}");
      handleCmd(payload);
      //handle command
    } else {
      //assume data message {CHECK FOR BULK}

      if (data['total'] == -1) {
        QMessage qMessage = QMessage.create();
        qMessage.mergeFromProto3Json(data, ignoreUnknownFields: true);
        for (BaseEntity baseEntity in qMessage.items) {
          beData[baseEntity.name] = baseEntity;
          this.be.add(baseEntity);
          beCallback(baseEntity);
        }
      } else if (data['data_type'] == "QBulkMessage") {
        QBulkMessage message = QBulkMessage.create();
        message.mergeFromProto3Json(data, ignoreUnknownFields: true);
        qb.add(message);
        message.messages.forEach((message) {
          message.items.forEach((baseentity) {
            handleMsg(data, beCallback, askCallback);
          });
        });
      } else {
        handleMsg(data, beCallback, askCallback);
      }
    }

  } 
  void handleCmd(CmdPayload payload
  ){
    _log.info("Got Cmd ${payload}");
    cmdMachine(payload);
  }
  void handleMsg(
    Map<String,dynamic> data,
    beCallback,
    askCallback,
  ) {
    if(data['data_type'] == 'BaseEntity') {
      BaseEntity be = BaseEntity.create()..mergeFromProto3Json(data, ignoreUnknownFields: true);
      beData[be.name] = be;
      beCallback(be);
    }
    else if (data['data_type'] == "Ask") {
      QDataAskMessage askmsg = QDataAskMessage.create()..mergeFromProto3Json(data);
      for(Ask ask in askmsg.items){
        for(Ask ask in ask.childAsks){
          askData[ask.questionCode] = ask;
        }
        askData[ask.questionCode] = ask;
      }
      
      
    }

  }

  Drawer createDrawer(BaseEntity be) {
    List<Widget> children = [];
    Drawer drawer = Drawer(
      child: SafeArea(
          child: ListView(
        children: children,
      )),
    );

    for (EntityAttribute attribute in be.baseEntityAttributes) {
      List<ExpansionPanel> listItems = [];
      List<Widget> buttons = [];
      buttons.add(ListTile(title: Text(attribute.attributeName)));
      Ask? ask;
      if (attribute.valueString.startsWith("QUE_")) {
        ask = askData[attribute.valueString];
      }
      askData[attribute.valueString];
      print("Full asks ${askData}");
      print(
          "Got asks with value ${attribute.valueString}${askData[attribute.valueString]}");
      // print("Got ask ${ask.firstWhere((element) {return element.attributeCode == attribute.attributeName;})}");
      // childAsk.childAsks.forEach((element) {
      //     listItems.add();
      // });
      if (askData[attribute.valueString] == 5) {
        children.add(ExpansionTile(
          leading: Container(
            width: 50,
            child: SvgPicture.network(
              "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                  attribute.attribute.icon,
              height: 30,
              width: 30,
            ),
          ),
          title: Text(ask.toString()),
          children: buttons,
        ));
        // content.children.add(DropdownButton(
        //   icon: SvgPicture.network(
        //     "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
        //         childAsk.question.icon,
        //     height: 30,
        //     width: 30,
        //   ),
        //   items: dropdownItems,
        //   onChanged: (value) {
        //     print("On changed $value");
        //   },
        // ));
      } else {
        children.add(
          ListTile(
              // style: TextButton.styleFrom(padding: EdgeInsets.zero),
              leading: Container(
                width: 50,
                child: SvgPicture.network(
                  "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                      (ask?.question.icon ?? "yeah lmao"),
                  height: 30,
                  width: 30,
                ),
              ),
              title: Text(ask?.name ??
                  "ATT ${attribute.attributeName} ${attribute.attributeCode}")),
        );
      }
    }
    return drawer;
  }


void displayMachine(CmdPayload payload) {
  _log.info("Displaying - $payload");
  switch(payload.code) {
    case "DRAWER:DETAIL":{
      break;
    }
    case "DIALOG_FORM": {
      break;
    }
    default: {
      _log.info("Default");
      state.DISPLAY = payload.code;
      state.DIALOG = 'NONE';
      state.DRAWER = 'NONE';
      state.DUPLICATE_EMAILS = '';
    }
  }
// const displayMachine: {
//   [key: string]: Function
// } = {
//   'DRAWER:DETAIL': (state: AppState) => (state['DRAWER'] = 'DETAIL'),
//   DIALOG_FORM: (state: AppState) => (state['DIALOG'] = 'FORM'),
//   NONE: (state: AppState) => {
//     state.DIALOG = 'NONE'
//     state.DRAWER = 'NONE'
//     state.DUPLICATE_EMAILS = ''
//   },
//   DEFAULT: (state: AppState, { code }: CmdPayload) => {
//     state['DISPLAY'] = code

//     state.DIALOG = 'NONE'
//     state.DRAWER = 'NONE'
//     state.DUPLICATE_EMAILS = ''
//   },
// }

}

void cmdMachine(CmdPayload payload) {
  switch (payload.cmdType) {
    case "DISPLAY": {
      displayMachine(payload);
      break;
    }
    case "TOAST": {
      break;
    }
    case "LOGOUT": {
      break;
    }
    case "DOWNLOAD_FILE": {
      break;
    }
    case "NOTES": {
      break;
    }
    default: {
      break;
    }
  }
  // DISPLAY: (state: AppState, { code }: CmdPayload) => {
  //   displayMachine[code]
  //     ? displayMachine[code](state, { code })
  //     : displayMachine.DEFAULT(state, { code })

  //   clearStateHandler(state, code)
  // },
  // TOAST: (state: AppState, payload: CmdPayload) => (state['TOAST'] = payload),
  // LOGOUT: (_: AppState, { exec }: CmdPayload) => {
  //   exec && (keycloak as any).logout()
  // },
  // DOWNLOAD_FILE: (state: AppState, { code, exec }: CmdPayload) => {
  //   if (exec) window.open(code)
  //   state.DOWNLOAD_FILE = code
  // },
  // NOTES: (state: AppState, { code }: CmdPayload) => {
  //   state['DRAWER'] = 'NOTES'
  //   state['NOTES'] = code
  // },
  // DEFAULT: (state: AppState, { targetCodes, code, cmd_type }: CmdPayload) => {
  //   if (targetCodes) {
  //     if (!equals(state[cmd_type], targetCodes)) state[cmd_type] = targetCodes
  //   } else {
  //     state[cmd_type] = code
  //   }
  // },
}
}