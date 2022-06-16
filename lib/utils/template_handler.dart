import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:geoff/geoff.dart';
import 'package:geoff/utils/networking/auth/session.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/messagedata.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/generated/qmessage.pb.dart';
import 'package:tommy/templates/tpl_appbar.dart';
import 'package:tommy/templates/tpl_cards_list_view.dart';
import 'package:tommy/templates/tpl_dashboard.dart';
import 'package:tommy/templates/tpl_detail_view.dart';
import 'package:tommy/templates/tpl_hidden_menu.dart';
import 'package:tommy/templates/tpl_hori.dart';
import 'package:tommy/templates/tpl_logo.dart';
import 'package:tommy/templates/tpl_sidebar.dart';
import 'package:tommy/templates/tpl_vert.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/proto_utils.dart';
import 'package:tommy/widgets/richtext_editor_widget.dart';
import 'package:tommy/widgets/timezone_widget.dart';
import '../generated/stream.pbgrpc.dart';

class TemplateHandler {
  // FocusNode focus;
  TemplateHandler();
  static Widget getTemplate(String code, BaseEntity entity) {
    switch (code) {
      case "TPL_VERT":
        {
          return Vert(entity: entity);
        }
      case "TPL_HORI":
        {
          return Hori(entity: entity);
        }
      case "TPL_PROGRESS_BAR":
        {
          return SizedBox();
        }
      case "TPL_FORM":
        {
          print(
              "Attribute code ${BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString}");
          // Ask qGroup = BridgeHandler.askData[BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString]!;
          //THIS IS HARD CODED FOR THE SAKE OF TESTING!
          //GET RID OF IT
          Ask qGroup = BridgeHandler.askData["QUE_TENANT_APPLICATION_GRP"]!;
          return ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: qGroup.childAsks.length,
            itemBuilder: ((context, index) {
              Ask returnAsk = qGroup.childAsks.elementAt(index);
              return TemplateHandler().getField(returnAsk, context);
            }),
          );
        }
      case "TPL_LOGO":
        {
          return Logo(
            entity: entity,
          );
        }
      case "TPL_HIDDEN_MENU":
        {
          return HiddenMenu(entity: entity);
        }
      case "TPL_NORTH":
        {
          return AppBarTpl(entity: entity);
        }
      case "TPL_SIDEBAR_1":
        {
          return Sidebar(entity: entity);
        }
      case "TPL_DASHBOARD_1":
        {
          return Dashboard(entity: entity);
        }
      case "TPL_DETAIL_VIEW1":
        {
          return DetailView(entity: entity);
        }
      case "TPL_CARDS_LIST_VIEW":
        {
          return CardsListView(entity: entity);
        }
      default:
        {
          return Text(code);
        }
    }
  }

  Widget getField(Ask ask, BuildContext context) {
    final stub = StreamClient(ProtoUtils.getChannel());
    switch (ask.question.attribute.dataType.component) {
      case "radio":
        {
          return Text("Radio what's new?");
        }
      case "dropdown":
        {
          return ExpansionTile(
            title: Text(ask.name),
            children: [
              TextButton(
                child: Text("Ordinarily items would go here"),
                onPressed: () {
                  BridgeHandler.answer(ask, "Dummy Dropdown");
                },
              ),
              Text(ask.toString())
            ],
          );
        }
      case "date":
        {
          return CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.fromMillisecondsSinceEpoch(0),
              lastDate: DateTime.now(),
              onDateChanged: (value) {
                print("Iso8601 ${DateFormat('y-M-d').format(value)}");
                BridgeHandler.answer(ask, DateFormat('y-M-d').format(value));
              });
        }
      case "time_zone":
        BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
        return TimezoneWidget(entity: entity, ask: ask);
      case "button":
        {
          print("Button entity $ask");
          // return Text("buttpn");
          return TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                print("After wait");
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
                print("Sinking... $submit");
                Future.delayed(Duration(seconds: 1), () {
                  BridgeHandler.submit(ask);
                });
              },
              child: Text(ask.name));
        }
      case "richtext_editor":
        {
          return RichtextEditor(
            ask: ask,
          );
        }

      default:
        {
          BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
          return ListTile(
            shape: ask.mandatory
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    side: BorderSide(color: Colors.redAccent, width: 2))
                : null,
            title: Focus(
              onFocusChange: ((focus) {
                if (!focus) {
                  BridgeHandler.answer(
                      ask,
                      BridgeHandler.findAttribute(entity, ask.attributeCode)
                          .valueString);
                }
              }),
              child: TextFormField(
                  onChanged: (value) {
                    BridgeHandler.findAttribute(entity, ask.attributeCode)
                        .valueString = value;
                  },
                  initialValue:
                      BridgeHandler.findAttribute(entity, ask.attributeCode)
                          .valueString,
                  autovalidateMode: AutovalidateMode.always,
                  validator: BridgeHandler.createValidator(ask),
                  onFieldSubmitted: (value) {
                    print("Field submitted $value");
                    BridgeHandler.answer(ask, value);
                  },
                  decoration: InputDecoration(
                    labelText:
                        "${ask.name} ${ask.question.attribute.dataType.component}",
                  )),
            ),
          );
        }
    }
  }

  static String fixLnkAndPri(String value) {
    return value.split('__')[0].replaceFirst('_', '');
  }

  static Widget AttributeWidget(EntityAttribute attribute, context) {
    DataType dataType = attribute.attribute.dataType;
    if (!attribute.attributeCode.startsWith("PRI_LOC")) {
      return SizedBox();
    }
    if (attribute.valueString.startsWith("PCM_")) {
      return BridgeHandler.getPcmWidget(attribute);
    }
    return IconButton(
        onPressed: () {
          /* # # # # #
          I would use the Geoff logger here but the standard dart print is far better at printing GRPC objects
      # # # # # */
          // ignore: avoid_print
          print(attribute);
        },
        icon: Icon(Icons.error));
  }
}
