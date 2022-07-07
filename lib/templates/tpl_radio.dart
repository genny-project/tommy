import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

class Radio extends StatelessWidget {
  final BaseEntity entity;
  const Radio({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Ask? qGroup = BridgeHandler.askData[BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString];
    return Column(
      children: List.generate(entity.baseEntityAttributes.length, (index) {
        return Text(entity.baseEntityAttributes.toString());
      }),
    );
  }
}
