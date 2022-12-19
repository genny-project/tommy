import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

class HoriAll extends StatelessWidget {
  final BaseEntity entity;
  const HoriAll({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // BaseEntity be =  BridgeHandler.findByCode(entity.baseEntityAttributes[index].baseEntityCode);
    EntityAttribute templateAttribute =
        BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE");
    Ask? ask = BridgeHandler.askData[templateAttribute.valueString]
      ?..childAsks.sort((a, b) => a.weight.compareTo(b.weight));

    if (ask == null) {
      return CircularProgressIndicator();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(ask.childAsks.length, (index) {
        return Expanded(
            child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal:
                  TemplateHandler.getDeviceSize(context).width * 1 / 100),
          child: ask.childAsks[index].field(context),
        ));
      }),
    );
  }
}
