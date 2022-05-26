import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geoff/utils/networking/auth/session.dart';
import 'package:geoff/utils/networking/gprc_utils.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/templates/tpl_logo.dart';

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
          return CalendarDatePicker(initialDate: DateTime.now(), firstDate: DateTime.fromMillisecondsSinceEpoch(0), lastDate: DateTime.now(), onDateChanged: (value){});
          // return Text("Date Range");
        }
      case "button":
        {
          return TextButton(onPressed: () {}, child: Text(ask.name));
        }
      default:
        {
          return ListTile(
            title: TextFormField(
                // controller: controllers[index],
          
                onFieldSubmitted: (value) {
                  // print("Value ${controllers[index]}");
                  Ask returnAsk = ask;
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
                          "processId": returnAsk.processId,
                          // "attributeCode": returnAsk.attributeCode,
                          // "code": "QUE_SUBMIT",
                          // "identifier": "QUE_SUBMIT",
                          // "weight": 1,
                          "value": value,
                          // "inferred": false
                        }
                      ]
                    });
                  stub.sink(answer);
                },
                decoration: InputDecoration(
                  hintText: ask.name +
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
