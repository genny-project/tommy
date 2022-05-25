import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

class Logo extends StatelessWidget {
  late final BaseEntity entity;
  
  Logo({required this.entity});
  @override
  Widget build(BuildContext context) {
    print("ValueString " + BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString);
    Ask ask = BridgeHandler.askData[BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString]!;
    print("Ask is $ask");
    print("Entity is $entity");
    return TextButton(
      // iconSize: 50,
      onPressed: (() {
        BridgeHandler.evt(ask.childAsks[1].question.attribute.code);
      }),
      child: Image.network(BridgeHandler.getPrimary(ask.childAsks[0].question.attribute.code).valueString));
  }
}