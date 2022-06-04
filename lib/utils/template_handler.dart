import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geoff/geoff.dart';
import 'package:geoff/utils/networking/auth/session.dart';
import 'package:geoff/utils/networking/gprc_utils.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/messagedata.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/generated/qmessage.pb.dart';
import 'package:tommy/templates/tpl_cards_list_view.dart';
import 'package:tommy/templates/tpl_dashboard.dart';
import 'package:tommy/templates/tpl_detail_view.dart';
import 'package:tommy/templates/tpl_logo.dart';
import 'package:tommy/templates/tpl_sidebar.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/proto_utils.dart';
// import 'package:tommy/utils/proto_utils.dart';

import '../generated/stream.pbgrpc.dart';

class TemplateHandler {
  static Widget getTemplate(String code, BaseEntity entity) {
    switch (code) {
      case "TPL_LOGO":
        {
          return Logo(
            entity: entity,
          );
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

  static Widget getField(Ask ask, BuildContext context) {
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
            children: [Text("Ordinarily items would go here")],
          );
        }
      case "date":
        {
          return CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.fromMillisecondsSinceEpoch(0),
              lastDate: DateTime.now(),
              onDateChanged: (value) {});
          // return Text("Date Range");
        }
      case "time_zone":
          return ListTile(
            title: TextButton(child: Text("Time Zone"), onPressed: (){
              showDialog(
                context: context,
                builder: ((context) {
                  return SimpleDialog(
                    title: Text("Select Time Zone"),
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          clipBehavior: Clip.antiAlias,
                          shrinkWrap: true,
                          itemCount: Timezones.timezones.length,
                          itemBuilder: ((context, index) {
                          return ListTile(title: Text(Timezones.timezones[index].text), onTap: (){
                            BridgeHandler.answer(ask, Timezones.timezones[index].utc.first);
                            Navigator.of(context).pop();
                          },);
                        })),
                      )
                    ],
                  );
              }));
            },),
          );
      case "button":
        {
          return TextButton(
              onPressed: () {
                Item submit = Item.create()
                  ..token = Session.token!..body = jsonEncode((QMessage.create()
                        ..eventType = "QUE_SUBMIT"
                        ..msgType = "EVT_MSG"
                        ..token = Session.tokenResponse!.accessToken!
                        ..data = (MessageData.create()
                          ..code = "QUE_SUBMIT"
                          ..platform.addAll({"type": "web"})
                          ..sessionId=Session.tokenData['jti']
                          ..processId= ask.processId
                        )
                      ).toProto3Json());
                print("Sinking... $submit");
                // stub.sink(submit);
                BridgeHandler.submit(ask);
              },
              child: Text(ask.name));
        }
      default:
        {
          BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
          // EntityAttribute attribute = BridgeHandler.findAttribute(entity, ask.attributeCode);
          // TextEditingController controller = TextEditingController();
          return ListTile(
            title: TextFormField(
              autovalidateMode: AutovalidateMode.always,
              // controller: controller,
              initialValue: BridgeHandler.findAttribute(entity, ask.attributeCode).valueString,
                validator: BridgeHandler.createValidator(ask),
                onFieldSubmitted: (value) {
                  print("Field submitted $value");
                  BridgeHandler.answer(ask, value);
                },
                decoration: InputDecoration(
                labelText: ask.name +
                      " " +
                      ask.question.attribute.dataType.component.toString(),
                )),
          );
        }
    }
  }
  // Map<String, Widget> templateMap = {
  // "TPL_LOGO": Logo(entity: entity,)
  // };
  // return templateMap[code]!;
  // }
}
