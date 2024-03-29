import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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
import 'package:tommy/pages/login.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/proto_utils.dart';
import 'package:tommy/utils/template_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class BridgeHandler {
  BridgeHandler();

  static final StreamClient client = StreamClient(ProtoUtils.getChannel());
  final Log _log = Log("BridgeHandler");
  static Map<String, BaseEntity> beData = {};
  static Map<String, Ask> askData = {};
  static Map<String, Attribute> attributeData = {};
  static ValueNotifier<Item> message = ValueNotifier<Item>(Item.create());
  static StreamController<BaseEntity> beStream = StreamController.broadcast();
  Set<String> images = {};

  static Map<String,dynamic> export() {
    List<String> beJson = [];
    List<String> askJson = [];
    Map<String,dynamic> bridgeEnv = BridgeEnv.data;
    beData.values.toSet().forEach((be) {beJson.add(be.writeToJson());});
    askData.values.toSet().forEach((ask) {askJson.add(ask.writeToJson());});
    return {"be": beJson, "ask": askJson, "env": bridgeEnv};
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
    client.sink(evtItem);
  }

  static void evt(
      {String? code,
      String? sourceCode,
      String? targetCode,
      String? parentCode,
      String? questionCode}) {
    Item evtItem = Item.create()
      ..token = Session.token!
      ..body = jsonEncode((QMessage.create()
            ..token = Session.tokenResponse!.accessToken!
            ..msgType = "EVT_MSG"
            ..eventType = "BTN_CLICK"
            ..redirect = true
            ..data = (MessageData.create()
              ..code = code ?? ""
              ..sourceCode = sourceCode ?? ""
              ..targetCode = targetCode ?? ""
              ..parentCode = parentCode ?? ""
              ..questionCode = questionCode ?? ""
              ..sessionId = Session.tokenData['jti']))
          .toProto3Json());
    client.sink(evtItem);
  }

  static void catchEvent(Ask ask) {
    switch (ask.questionCode) {
      case "QUE_AVATAR_LOGOUT":
        {
          beData = {};
          askData = {};
          attributeData = {};
          client.sink(Item.create()
            ..token = Session.token!
            ..body = jsonEncode((QMessage.create()
                  ..token = Session.token!
                  ..data = (MessageData.create()..code = "LOGOUT")
                  ..msgType = "EVT_MSG"
                  ..eventType = "LOGOUT"
                  ..redirect = true)
                .toProto3Json()));

          Session.onLogout();
          Session.tokenResponse = null;
          AppAuthHelper.logout().then((value) => navigatorKey.currentState
              ?.pushReplacement(
                  MaterialPageRoute(builder: (context) => Login())));

          break;
        }
      case "QUE_AVATAR_SETTINGS":
        {
          launchUrl(
              Uri.parse(
                "${BridgeEnv.ENV_KEYCLOAK_REDIRECTURI}/realms/internmatch/account",
              ),
              mode: LaunchMode.externalApplication);
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
              ..attributeCode = ask.attributeCode
              ..processId = ask.processId
              ..value = value))
          .toProto3Json());
    client.sink(answerItem);
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
    client.sink(submit);
  }

  void handleData(Map<String, dynamic> data,
      {required Function(QDataAskMessage ask) askCallback,
      required Function(BaseEntity be) beCallback}) async {
    if (data['msg_type'] == "CMD_MSG") {
      CmdPayload payload = CmdPayload.create()
        ..mergeFromProto3Json(data, ignoreUnknownFields: true);
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
          //maybe not? this works relatively well to avoid storing the full message data
          //not exactly fond of this workaround
          be.parentCode = qMessage.parentCode;
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
    MyApp.changeTheme(theme);
  }

  Future<void> handleAsk(Ask ask, askCallback) async {
    askData[ask.question.code] = ask;
    if (ask.question.icon.isNotEmpty) {
      if (!images.contains(ask.question.icon)) {
        images.add(ask.question.icon);
        SvgPicture picture = SvgPicture.network(
            '${BridgeEnv.ENV_MEDIA_PROXY_URL}/${ask.question.icon}');
        http.Response response = await http
            .get(Uri.parse((picture.pictureProvider as NetworkPicture).url));
        if (response.statusCode == 200) {
          precachePicture(picture.pictureProvider, null);
        } else {
          _log.info(
              "Could not load image ${picture.pictureProvider} : ${ask.question.code}");
        }
      }
    }
    if (ask.childAsks.isNotEmpty) {
      for (Ask ask in ask.childAsks) {
        handleAsk(ask, askCallback);
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
          .error("The entity provided contains no attributes $attributeName");
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
  static String? Function(String?) createValidator(Ask ask, {String? value}) {
    List validationList = ask.question.attribute.dataType.validationList;
    String? regex = validationList.isNotEmpty ? validationList.first.regex : "";
    RegExp regExp = RegExp(regex!);
    return (string) {
      String? stringValue;
      stringValue = value ?? string;
      if (!regExp.hasMatch(stringValue!) && stringValue.isNotEmpty) {
        return "Please enter valid data";
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

  static ThemeData get theme {
    BaseEntity project = getProject();
    Color getColor(String code) {
      EntityAttribute att = findAttribute(project, code);
      if (att.attributeCode != "ERR") {
        return Color(int.parse("ff${att.valueString.substring(1)}", radix: 16));
      }
      return Colors.black;
    }

    return ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
        ),
        drawerTheme:
            DrawerThemeData(backgroundColor: getColor('PRI_COLOR_PRIMARY')),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: getColor('PRI_COLOR_SECONDARY'),
          linearTrackColor: Colors.transparent,
        ),
        colorScheme: ColorScheme(
            background: getColor('PRI_COLOR_BACKGROUND'),
            onBackground: getColor('PRI_COLOR_BACKGROUND_ON'),
            surface: getColor('PRI_COLOR_SURFACE'),
            onSurface: getColor('PRI_COLOR_SURFACE_ON'),
            primary: getColor('PRI_COLOR_PRIMARY'),
            onPrimary: getColor('PRI_COLOR_PRIMARY_ON'), //TODO: correct this when the values are set properly
            error: getColor('PRI_COLOR_ERROR_ON'),
            onError: getColor('PRI_COLOR_ERROR_ON'),
            brightness: Brightness.light,
            secondary: getColor('PRI_COLOR_SECONDARY'),
            onSecondary: getColor('PRI_COLOR_SECONDARY_ON')));
  }

  static BaseEntity getProject() {
    //IM uses the incorrect name for its project BE so this function (essentially a wildcard) is necessary
    return beData[beData.keys.firstWhere(
      (key) {
        return key.startsWith('PRJ');
      },
    )]!;
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
