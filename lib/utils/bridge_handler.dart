import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geoff/geoff.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/cmdpayload.pb.dart';
import 'package:tommy/generated/messagedata.pb.dart';
import 'package:tommy/generated/qbulkmessage.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/generated/qmessage.pb.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/models/state.dart';
import 'package:tommy/utils/proto_utils.dart';
import 'package:tommy/utils/template_handler.dart';

class BridgeHandler {
  BridgeHandler(this.state);
  AppState state;

  static final stub = StreamClient(ProtoUtils.getChannel());
  final Log _log = Log("BridgeHandler");
  static Map<String, BaseEntity> beData = {};
  static Map<String, Ask> askData = {};
  // static List<BaseEntity> be = [];
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

  static void evt(String code) {
    stub.sink(Item.create()
      ..token = Session.token!
      ..body = jsonEncode((QMessage.create()
            ..token = Session.tokenResponse!.accessToken!
            ..msgType = "EVT_MSG"
            ..eventType = "BTN_CLICK"
            ..redirect = true
            ..data = (MessageData.create()
              ..code = code
              ..parentCode = code))
          .toProto3Json()));
  }

  static void answer(Ask ask, dynamic value) {
    Item answer = Item.create()
      ..token = Session.token!
      ..body = jsonEncode({
        "event_type": "QUE_ANSWER",
        "msg_type": "DATA_MSG",
        "token": Session.tokenResponse!.accessToken!,
        "items": [
          {
            "questionCode": ask.questionCode,
            "sourceCode": ask.sourceCode,
            "targetCode": ask.targetCode,
            "askId": ask.id.toInt(),
            "pcmCode": ask.question.attribute.code,
            "attributeCode": ask.question.attributeCode,
            "processId": ask.processId,
            "value": value,
          }
        ]
      });
    stub.sink(answer);
  }

  static void submit(Ask ask) {
    Item submit = Item.create()
      ..token = Session.token!
      ..body = jsonEncode((QMessage.create()
            ..eventType = "QUE_SUBMIT"
            ..msgType = "EVT_MSG"
            ..token = Session.tokenResponse!.accessToken!
            ..data = (MessageData.create()
              ..code = "QUE_SUBMIT"
              ..platform.addAll({"type": "web"})
              ..sessionId = Session.tokenData['jti']
              ..processId = ask.processId))
          .toProto3Json());
    stub.sink(submit);
  }

  void handleData(Map<String, dynamic> data,
      {required Function(QDataAskMessage ask) askCallback,
      required Function(BaseEntity be) beCallback}) {
    // _log.info("Data msg_type ${data['msg_type']}");
    if (data['msg_type'] == "CMD_MSG") {
      CmdPayload payload = CmdPayload.create()
        ..mergeFromProto3Json(data, ignoreUnknownFields: true);
      _log.info("CMD PAYLOAD ${payload.cmdType}");
      handleCmd(payload);
      //handle command
    } else {
      //assume data message {CHECK FOR BULK}
      if (data['total'] == -1) {
        QMessage qMessage = QMessage.create();
        qMessage.mergeFromProto3Json(data, ignoreUnknownFields: true);
        for (BaseEntity baseEntity in qMessage.items) {
          handleBE(baseEntity, beCallback);
          // beData[baseEntity.name] = baseEntity;
          // be.add(baseEntity);
          // beCallback(baseEntity);
        }
      } else if (data['data_type'] == "QBulkMessage") {
        QBulkMessage message = QBulkMessage.create();
        message.mergeFromProto3Json(data, ignoreUnknownFields: true);
        qb.add(message);
        for (QMessage message in message.messages) {
          Map<String, dynamic> json =
              message.toProto3Json() as Map<String, dynamic>;
          _log.info("the type is ${json['dataType']}");
          for (BaseEntity be in message.items) {
            handleBE(be, beCallback);
          }
          // handleMsg(json, beCallback, askCallback);
        }
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
      try {
        QMessage qMessage = QMessage.create()
          ..mergeFromProto3Json(data, ignoreUnknownFields: true);
        _log.info("Created qmessage");
        _log.info("Data ${data.keys.toList()}");
        for (BaseEntity be in qMessage.items) {

          handleBE(be, beCallback);
        }
      } catch (e) {
        _log.error("Could not create qMessage. $e");
      }
    } else if (data['data_type'] == "Ask") {
      try {
        QDataAskMessage askmsg = QDataAskMessage.create()
          ..mergeFromProto3Json(data, ignoreUnknownFields: true);
        askCallback(askmsg);
        for (Ask ask in askmsg.items) {
          handleAsk(ask, askCallback);
          // for (Ask ask in ask.childAsks) {
          //   askData[ask.questionCode] = ask;
          // }
          // askData[ask.questionCode] = ask;
        }
      } catch (e) {
        _log.error("FAILED TO MERGE $data");
      }
    }
  }

  void handleBE(BaseEntity entity, beCallback) {
    beData[entity.code] = entity;
    // be.add(entity);
    // beData[be.code] = be;

    beCallback(entity);
  }

  void handleAsk(Ask ask, askCallback) {
    askData[ask.question.code] = ask;
    if (ask.childAsks.isNotEmpty) {
      print("got child asks");
      for (Ask ask in ask.childAsks) {
        handleAsk(ask, askCallback);
      }
    }
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
  }


  //TODO: this function may not be necessary anymore due to BeData changes
  //worth having just for error handling at this point
  static BaseEntity findByCode(String code) {
    BaseEntity entity;
    try {
      entity = beData[code]!;
      return entity;
    } catch (e) {
      throw ArgumentError("Could not find BaseEntity", code);
    }
  }

  static Ask findBySourceCode(String code) {
    return askData.values.firstWhere((ask) => ask.sourceCode == code,
        orElse: () {
      throw ArgumentError("Could not find ask", code);
    });
  }

  /// Find a baseEntityAttribute from a [BaseEntity] object where the
  /// [BaseEntity.attributeCode] is equal to `attributeName`
  static EntityAttribute findAttribute(
      BaseEntity entity, String attributeName) {
    if (entity.baseEntityAttributes.isEmpty) {
      throw ArgumentError(
          "The entity provided contains no attributes", entity.code);
    }
    try {
      EntityAttribute attribute = entity.baseEntityAttributes
          .firstWhere((attribute) => attribute.attributeCode == attributeName);
      return attribute;
    } catch (e) {
      throw ArgumentError("The Attribute does not exist", attributeName);
    }
  }

  static String? Function(String?) createValidator(Ask ask) {
    String regex = ask.question.attribute.dataType.validationList.first.regex;
    RegExp regExp = RegExp(regex);
    return (string) {
      if (!regExp.hasMatch(string!)) {
        return "Does not match regex";
      }
    };
  }

  static Widget getPcmWidget(EntityAttribute attribute) {
    BaseEntity be = findByCode(attribute.valueString);
    EntityAttribute templateAttribute = findAttribute(be, "PRI_TEMPLATE_CODE");
    print(templateAttribute.valueString);
    Widget entityWidget;
    try {
      entityWidget = TemplateHandler.getTemplate(templateAttribute.valueString, be);
    } catch (e) {
      throw ArgumentError(e);
    }
    return entityWidget;
  }

  Widget typeSwitch(Ask ask) {
    switch (ask.question.attribute.dataType.dttCode) {
      case "DTT_IMAGE":
        {
          return Image.network(
            getPrimary(ask.question.attribute.code).valueString,
            headers: {"Authorization": "Bearer ${Session.token}"},
          );
        }
      default:
        {
          return Text(ask.question.attribute.dataType.dttCode);
        }
    }
  }

  static BaseEntity getProject() {
    String realm =
        Session.tokenData['iss'].toString().split("/").last.toUpperCase();
    return findByCode("PRJ_" + realm);
  }

  static EntityAttribute getPrimary(String code) {
    return findAttribute(getProject(), code);
  }
}
