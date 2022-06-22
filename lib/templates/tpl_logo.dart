import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

class Logo extends StatelessWidget {
  final BaseEntity entity;
  const Logo({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Ask ask = BridgeHandler.askData[BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString]!;
    return TextButton(
      // iconSize: 50,
      onPressed: (() {
        BridgeHandler.evt(ask.childAsks[1].question.attribute.code);
      }),
      child: CachedNetworkImage(
       imageUrl: BridgeHandler.getPrimary(ask.childAsks[0].question.attribute.code).valueString,));
  }
}