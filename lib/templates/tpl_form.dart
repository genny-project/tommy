import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/template_handler.dart';

import '../utils/bridge_handler.dart';

class GennyForm extends StatefulWidget {
  final BaseEntity entity;
  const GennyForm({Key? key, required this.entity}) : super(key: key);

  @override
  State<GennyForm> createState() => _GennyFormState();
}

class _GennyFormState extends State<GennyForm> {
  void initState() {
    super.initState();

    //   static void evt(Ask ask) {
    //   stub.sink(Item.create()
    //     ..token = Session.token!
    //     ..body = jsonEncode((QMessage.create()
    //           ..token = Session.tokenResponse!.accessToken!
    //           ..msgType = "EVT_MSG"
    //           ..eventType = ask.questionCode
    //           ..redirect = true
    //           ..data = (MessageData.create()
    //             ..code = ask.questionCode
    //             ..parentCode = ask.questionCode
    //             ..sessionId = Session.tokenData['jti']
    //             ..processId = ask.processId))
    //         .toProto3Json()));
    // }
  }

  @override
  Widget build(BuildContext context) {
    Ask? qGroup = BridgeHandler
        .askData[widget.entity.findAttribute("PRI_QUESTION_CODE").valueString]?..childAsks.sort(((a, b) {
          return a.weight.compareTo(b.weight);
        }));

    if (qGroup != null) {
      return Column(
          children: List.generate(qGroup.childAsks.length, (index) {
        if (qGroup.childAsks[index].attributeCode == "QQQ_QUESTION_GROUP") {
          Ask ask = qGroup.childAsks[index];
          return Column(
            children: List.generate(
                ask.childAsks.length,
                (index) =>
                    TemplateHandler().getField(ask.childAsks[index], context)),
          );
        }
        return TemplateHandler()
            .getField(qGroup.childAsks.elementAt(index), context);
      }));
    } else {
      return const LinearProgressIndicator();
    }
  }
}
