import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoff/geoff.dart';
import 'package:tommy/generated/answer.pb.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/cmdpayload.pb.dart';
import 'package:tommy/generated/messagedata.pb.dart';
import 'package:tommy/generated/qbulkmessage.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/generated/qmessage.pb.dart';
import 'package:tommy/generated/stream.pbgrpc.dart';
import 'package:tommy/main.dart';
import 'package:tommy/models/state.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/proto_utils.dart';
import 'package:tommy/utils/template_handler.dart';

class BridgeHandler {
  BridgeHandler(this.state);
  AppState state;

  static final stub = StreamClient(ProtoUtils.getChannel());
  final Log _log = Log("BridgeHandler");
  static Map<String, BaseEntity> beData = {};
  static Map<String, Ask> askData = {};
  static Map<String, Attribute> attributeData = {};
  static ValueNotifier<Item> message = ValueNotifier<Item>(Item.create());
  static StreamController<BaseEntity> beStream = StreamController.broadcast();
  static final Stream<Item> stream = StreamClient(ProtoUtils.getChannel())
      .connect(Item.create()
        ..token = Session.tokenResponse!.accessToken!
        ..body = jsonEncode({'connect': 'connect'}))
      .asBroadcastStream();

  /*-----------------------------------
    Should rethink this appstate function, a carryover from attempting to emulate Alyson
    PCM_ROOT handles all of this way better
  -----------------------------------*/
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
  }

  static dynamic getValue(EntityAttribute attribute) {
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
      case "LocalDate":
        {
          return attribute.valueDate;
        }
      case "Time":
        {
          return attribute.valueTime;
        }
      case "DateTime":
        {
          return attribute.valueDateTime;
        }
      case "Long":
        {
          return attribute.valueLong;
        }
      case "Money":
        {
          return attribute.valueMoney;
        }
      case "Double":
        {
          return attribute.valueDouble;
        }
      default:
        {
          return "N/A";
        }
    }
  }

  static void askEvt(Ask ask, [String? eventType]) {
    Item evtItem = Item.create()
      ..token = Session.token!
      ..body = jsonEncode((QMessage.create()
            ..token = Session.tokenResponse!.accessToken!
            ..msgType = "EVT_MSG"
            ..eventType = eventType ?? "BTN_CLICK"
            ..redirect = true
            ..attributeCode = ask.attributeCode
            ..data = (MessageData.create()
              ..code = ask.questionCode
              ..questionCode = ask.questionCode
              ..sourceCode = ask.sourceCode
              ..targetCode = ask.targetCode
              ..parentCode = ""
              ..value = ask.value
              ..sessionId = Session.tokenData['jti']
              ..processId = ask.processId))
          .toProto3Json());
    //temporary handler for logout and so forth
    //will use until we have real event handling
    catchEvent(ask);
    stub.sink(evtItem);
  }

  static void evt(
      {required String code,
      required String sourceCode,
      required String targetCode,
      required String parentCode}) {
    Item evtItem = Item.create()
      ..token = Session.token!
      ..body = jsonEncode((QMessage.create()
            ..token = Session.tokenResponse!.accessToken!
            ..msgType = "EVT_MSG"
            ..eventType = "BTN_CLICK"
            ..redirect = true
            ..data = (MessageData.create()
              ..code = code
              ..sourceCode = sourceCode
              ..targetCode = targetCode
              ..parentCode = parentCode
              ..questionCode = "QUE_PROPERTIES"
              ..sessionId = Session.tokenData['jti']))
          .toProto3Json());
    stub.sink(evtItem);
  }

  static void catchEvent(Ask ask) {
    switch (ask.questionCode) {
      case "QUE_AVATAR_LOGOUT":
        {
          beData = {};
          askData = {};
          AppAuthHelper.logout();
          navigatorKey.currentState?.pop();
          break;
        }
      default:
        {
          break;
        }
    }
  }
  //neither alyson nor gadaq have a real object/interface for this
  //so i threw one together myself, might need to reconsider it later
  //thats assuming we get around to actually sending real protobuf objects

  //also going to make this asynchronous so it doesnt speed bump the form
  static void answer(Ask ask, dynamic value) async {
    Item answerItem = Item.create()
      ..token = Session.token!
      ..body = jsonEncode((AnswerMsg.create()
            ..msgType = "DATA_MSG"
            ..token = Session.tokenResponse!.accessToken!
            ..items.add(Answer.create()
              ..sourceCode = ask.sourceCode
              ..targetCode = ask.targetCode
              ..askId = ask.id
              ..attributeCode = ask.question.attributeCode
              ..processId = ask.processId
              ..value = value))
          .toProto3Json());
    stub.sink(answerItem);
  }

  //likewise i dont think qmessage is the dedicated class for this, but it fits
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
      required Function(BaseEntity be) beCallback}) async {
    if (data['msg_type'] == "CMD_MSG") {
      CmdPayload payload = CmdPayload.create()
        ..mergeFromProto3Json(data, ignoreUnknownFields: true);
      handleCmd(payload);
    } else {
      /*--------------------------------------------
        Probably vestigal, it used to be the only way to distinguish a PCM message from an ordinary message
        Unsure if this is still the case on internmatch, but it is absolutely unnecessary on lojing
      --------------------------------------------*/
      // // // if (data['total'] == -1) {
      // // //   QMessage qMessage = QMessage.create();
      // // //   qMessage.mergeFromProto3Json(data, ignoreUnknownFields: true);
      // // //   for (BaseEntity baseEntity in qMessage.items) {
      // // //     handleBE(baseEntity, beCallback);
      // // //   }
      // // // }
      if (data['data_type'] == "Attribute") {
        for (Map<String, dynamic> item in data['items']) {
          Attribute attribute = Attribute.create()..mergeFromProto3Json(item);
          attributeData[attribute.code] = attribute;
          // print("Attribute received - $attribute");
        }
      }
      if (data['data_type'] == "QBulkMessage") {
        QBulkMessage message = QBulkMessage.create();

        message.mergeFromProto3Json(data, ignoreUnknownFields: true);

        for (QMessage message in message.messages) {
          Map<String, dynamic> json =
              message.toProto3Json() as Map<String, dynamic>;
          _log.info("the type is ${json['dataType']}");
          for (BaseEntity be in message.items) {
            if (message.parentCode.startsWith("SBE_")) {
              be.parentCode = message.parentCode;
            }
            handleBE(be, beCallback);
          }
        }
      } else {
        handleMsg(data, beCallback, askCallback);
      }
    }
  }

  Future<void> handleCmd(CmdPayload payload) async {
    cmdMachine(payload);
  }

  Future<void> handleMsg(
    Map<String, dynamic> data,
    beCallback,
    askCallback,
  ) async {
    if (data['data_type'] == 'BaseEntity') {
      try {
        QMessage qMessage = QMessage.create()
          ..mergeFromProto3Json(data, ignoreUnknownFields: true);
        for (BaseEntity be in qMessage.items) {
          //TODO: work out a better solution than this
          //not exactly fond of this workaround
          be.parentCode = qMessage.questionCode;
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
        }
      } catch (e) {
        _log.error("FAILED TO MERGE $data");
        _log.error(e);
      }
    }
  }

  Future<void> handleBE(BaseEntity entity, beCallback) async {
    beData[entity.code] = entity;
    if (entity.code.startsWith('PRJ_')) handlePRJ(entity);
    beStream.stream.contains(entity);
    beStream.add(entity);
    beCallback(entity);
  }

  void handlePRJ(BaseEntity entity) {
    _log.info("Got project ${entity.code}");
    MyApp.changeTheme(getTheme());
  }

  Future<void> handleAsk(Ask ask, askCallback) async {
    askData[ask.question.code] = ask;
    if (ask.question.icon.isNotEmpty) {
      try {
        SvgPicture picture = SvgPicture.network(
            '${BridgeEnv.ENV_MEDIA_PROXY_URL}/${ask.question.icon}');
        precachePicture(picture.pictureProvider, null);
      } catch (e) {
        _log.warning("Could not pre cache svg from network.");
      }
    }
    if (ask.childAsks.isNotEmpty) {
      for (Ask ask in ask.childAsks) {
        handleAsk(ask, askCallback);
      }
    }
  }

  /*------
    more carryovers from alyson
    nested PCMs and root is far more elegant than this
  ------*/
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

  //quod superius macroprosopus, quod inferius microprosopus
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

  static BaseEntity findByCode(String code) {
    BaseEntity entity;
    try {
      entity = beData[code]!;
      return entity;
    } catch (e) {
      Log("findByCode").error("Could not find base entity - $code");
      return BaseEntity.create();
    }
  }

  static Future<BaseEntity>? awaitBe(String code) async {
    Completer<BaseEntity> completer = Completer();
    if (beData[code] != null) {
      return beData[code]!;
    }

    StreamSubscription<BaseEntity> stream = beStream.stream.listen((entity) {
      if (entity.code.startsWith(code)) {
        completer.complete(entity);
      }
    });
    BaseEntity out = await completer.future;
    stream.cancel();
    return out;
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
      Log("")
          .error("The entity provided contains no attributes ${entity.code}");
    }
    try {
      EntityAttribute attribute = entity.baseEntityAttributes
          .firstWhere((attribute) => attribute.attributeCode == attributeName);
      return attribute;
    } catch (e) {
      // _log.info("String SSS!");
      // throw ArgumentError("The Attribute does not exist", attributeName);
      return EntityAttribute.create()
        ..attributeCode = "ERR"
        ..description = e.toString();
    }
  }

  ///Creates a text field validation function from the validation list of an [Ask] object
  ///
  ///Presently only contains Regex functionality
  static String? Function(String?) createValidator(Ask ask) {
    List validationList = ask.question.attribute.dataType.validationList;
    String? regex = validationList.isNotEmpty ? validationList.first.regex : "";
    RegExp regExp = RegExp(regex!);
    return (string) {
      if (!regExp.hasMatch(string!) && string.isNotEmpty) {
        return "Does not match regex";
      }
      return null;
    };
  }

  static Widget getPcmWidget(EntityAttribute attribute) {
    BaseEntity be;
    try {
      be = findByCode(attribute.valueString);
    } catch (e) {
      return ErrorWidget(e);
    }
    EntityAttribute templateAttribute = findAttribute(be, "PRI_TEMPLATE_CODE");
    Widget entityWidget;
    try {
      entityWidget =
          TemplateHandler.getTemplate(templateAttribute.valueString, be);
    } catch (e) {
      Log("BridgeHandler").info(
          "Could not get PCM widget ${be.code} ${templateAttribute.valueString} $e");
      entityWidget = ErrorWidget(ArgumentError(
          "Could not get PCM widget ${be.code} ${templateAttribute.valueString} $e",
          be.code));
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

  static ThemeData getTheme() {
    BaseEntity project = getProject();
    Color? getColor(String code) {
      EntityAttribute att = findAttribute(project, code);
      if (att.attributeCode != "ERR") {
        return Color(int.parse("ff${att.valueString.substring(1)}", radix: 16));
      }
      return Colors.black;
      // return Colors.black;
    }

    return ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
        ),
        drawerTheme:
            DrawerThemeData(backgroundColor: getColor('PRI_COLOR_PRIMARY')),
        colorScheme: ColorScheme(
            //these fallbacks are temporary. ideally we should always get all of these
            background:
                getColor('PRI_COLOR_BACKGROUND') ?? Colors.white, //_SURFACE
            onBackground: getColor('PRI_COLOR_BACKGROUND_ON') ?? Colors.black,
            surface: getColor('PRI_COLOR_SURFACE') ?? Colors.red,
            onSurface: getColor('PRI_COLOR_SURFACE_ON') ?? Colors.grey,
            primary: getColor('PRI_COLOR_PRIMARY') ?? Colors.yellow,
            onPrimary: getColor('PRI_COLOR_PRIMARY_ON') ?? Colors.white,
            error: getColor('PRI_COLOR_ERROR_ON') ?? Colors.red,
            onError: getColor('PRI_COLOR_ERROR_ON') ?? Colors.red,
            brightness: Brightness.light,
            secondary: getColor('PRI_COLOR_SECONDARY') ?? Colors.amber,
            onSecondary: getColor('PRI_COLOR_SECONDARY_ON') ?? Colors.teal));
  }

  static BaseEntity getProject() {
    String realm = BridgeEnv.clientID.toUpperCase();
    return findByCode("PRJ_$realm");
  }

  static BaseEntity? getUser() {
    return beData[beData.keys.lastWhere((key) => key.startsWith("PER_"))];
  }

  static EntityAttribute getPrimary(String code) {
    EntityAttribute attribute;
    try {
      attribute = findAttribute(getProject(), code);
    } catch (e) {
      attribute = EntityAttribute.create()
        ..attributeCode = "ERR"
        ..valueString = e.toString();
    }
    return attribute;
  }
}
