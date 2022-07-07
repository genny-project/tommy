import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/template_handler.dart';

import '../utils/bridge_handler.dart';

class GennyForm extends StatelessWidget {
  final BaseEntity entity;
  const GennyForm({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Ask? qGroup = BridgeHandler.askData[
        BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString];

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
