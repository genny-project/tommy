import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

class Hori extends StatelessWidget {
  late final BaseEntity entity;

  Hori({required this.entity});
  @override
  Widget build(BuildContext context) {
    // Ask ask = BridgeHandler.askData[BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString]!;
    // return Text("This ought to be horizontal");
    // return Row(
    //   children: [
    //     TemplateHandler.AttributeWidget(entity.baseEntityAttributes[1], context)
    //   ],
    // );
    return Column(children: List.generate(entity.baseEntityAttributes.length, (index) {
      return TemplateHandler.AttributeWidget(entity.baseEntityAttributes[index], context);
    }),);
    return ListView.builder(
        itemExtent: 150.0,
        scrollDirection: Axis.horizontal,
        itemCount: entity.baseEntityAttributes.length,
        itemBuilder: (context, index) {
          print(
              "Value string " + entity.baseEntityAttributes[index].valueString);
          return TemplateHandler.AttributeWidget(
              entity.baseEntityAttributes[index], context);
        });
  }
}
