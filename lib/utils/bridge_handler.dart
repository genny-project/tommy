import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoff/geoff.dart';
import 'package:minio/models.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/baseentity.pbjson.dart';
import 'package:tommy/generated/cmdpayload.pb.dart';
import 'package:tommy/generated/messagedata.pb.dart';
import 'package:tommy/generated/msgpayload.pb.dart';
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
        DIALOG: 'NONE',
        TOAST: null,
        DASHBOARD_COUNTS: null,
        NOTES: '',
        DUPLICATE_EMAILS: '',
        lastSentMessage: {
          'time': '',
          'data': {
            'data': {'code': 'QUE_DASHBOARD_VIEW'}
          }
        },
        lastReceivedMessage: {},
        highlightedQuestion: '');
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
    // _log.info("Data msg_type ${data['msg_type']}");
    print("Got data ${data.toString().length} $data");
    if (data['msg_type'] == "CMD_MSG") {
      CmdPayload payload = CmdPayload.create()
        ..mergeFromProto3Json(data, ignoreUnknownFields: true);
      _log.info("CMD PAYLOAD ${payload.cmdType}");
      handleCmd(payload);
      //handle command
    } else {
      //assume data message {CHECK FOR BULK}
      if (data['total'] == -1) {
        print("total -1 ${data}");
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
          Map<String, dynamic> json =
              message.toProto3Json() as Map<String, dynamic>;
          _log.info("the type is ${json['dataType']}");
          message.items.forEach((be) {
            handleBE(be, beCallback);
          });
          // handleMsg(json, beCallback, askCallback);
        });
      } else {
        handleMsg(data, beCallback, askCallback);
      }
    }
  }

  void handleCmd(CmdPayload payload) {
    _log.info("Got Cmd ${payload}");
    cmdMachine(payload);
  }

  void handleMsg(
    Map<String, dynamic> data,
    beCallback,
    askCallback,
  ) {
    if (data['data_type'] == 'BaseEntity') {
      BaseEntity be = BaseEntity.create()
        ..mergeFromProto3Json(data, ignoreUnknownFields: true);
      handleBE(be, beCallback);
    } else if (data['data_type'] == "Ask") {
      print("Got ask!! $data");
      Clipboard.setData(ClipboardData(text: data.toString()));
      try {
        QDataAskMessage askmsg = QDataAskMessage.create()
          ..mergeFromProto3Json(data, ignoreUnknownFields: true);
        askCallback(askmsg);
        for (Ask ask in askmsg.items) {
          for (Ask ask in ask.childAsks) {
            askData[ask.questionCode] = ask;
          }
          askData[ask.questionCode] = ask;
        }
      } catch (e) {
        Clipboard.setData(ClipboardData(text: data.toString()));
        _log.error("FAILED TO MERGE $data");
      }
    }
  }

  void handleBE(BaseEntity be, beCallback) {
    beData[be.code] = be;
    beCallback(be);
  }

  void displayMachine(CmdPayload payload) {
    _log.info("Displaying - $payload");
    switch (payload.code) {
      case "DRAWER:DETAIL":
        {
          break;
        }
      case "DIALOG_FORM":
        {
          break;
        }
      default:
        {
          _log.info("Default");
          state.DISPLAY = payload.code;
          state.DIALOG = 'NONE';
          state.DRAWER = 'NONE';
          state.DUPLICATE_EMAILS = '';
        }
    }
  }

  void cmdMachine(CmdPayload payload) {
    switch (payload.cmdType) {
      case "DISPLAY":
        {
          displayMachine(payload);
          break;
        }
      case "TOAST":
        {
          break;
        }
      case "LOGOUT":
        {
          break;
        }
      case "DOWNLOAD_FILE":
        {
          break;
        }
      case "NOTES":
        {
          break;
        }
      default:
        {
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

  BaseEntity findByCode(String code) {
    return be.firstWhere((be) => be.code == code, orElse: () {
      throw ArgumentError("Could not find BaseEntity", code);
    });
  }

  /// Find a baseEntityAttribute from a [BaseEntity] object where the
  /// [BaseEntity.attributeCode] is equal to `attributeName`
  EntityAttribute findAttribute(BaseEntity entity, String attributeName) {
    entity.baseEntityAttributes.forEach((element) {
      print(element.attributeCode);
    });
    if (entity.baseEntityAttributes.isEmpty) {
      throw ArgumentError(
          "The entity provided contains no attributes", entity.code);
    }
    try {
      EntityAttribute attribute = entity.baseEntityAttributes
          .firstWhere((attribute) => attribute.attributeCode == attributeName);
      return attribute;
    } catch (e) {
      // result = BaseEntity.create()..code = "NONE";
      throw ArgumentError("The Attribute does not exist", attributeName);
    }
    // return result;
  }

  String? Function(String?) createValidator(EntityAttribute attribute) {
    String regex = attribute.attribute.dataType.validationList.first.regex;
    print("Got regex $regex");
    RegExp regExp = RegExp(regex);
    return (string){
      if(!regExp.hasMatch(string!)) {
        return "Does not match regex";
      }
    };
  }
}

