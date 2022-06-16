import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

class Vert extends StatelessWidget {
  late final BaseEntity entity;

  Vert({required this.entity});
  @override
  Widget build(BuildContext context) {
    // Ask ask = BridgeHandler.askData[BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString]!;
    return Column(children: List.generate(entity.baseEntityAttributes.length, (index) {
      return TemplateHandler.AttributeWidget(entity.baseEntityAttributes[index], context);
    }),);
    return ListView.builder(
      itemExtent: 150,
        // primary: false,
          // shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          itemCount: entity.baseEntityAttributes.length,
          itemBuilder: (context, index) {
            return TemplateHandler.AttributeWidget(
                entity.baseEntityAttributes[index], context);
          });
    
  }
}
