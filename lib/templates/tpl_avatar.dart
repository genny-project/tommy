import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

import 'package:tommy/utils/bridge_extensions.dart';
class AvatarTpl extends StatelessWidget {
  // TODO: sort this out once this is a PCM
  final BaseEntity entity;
  // late final Ask? ask = BridgeHandler.askData[entity.baseEntityAttributes.first.valueString];
  // ignore: unused_field
  late final Log _log = Log(runtimeType.toString());
  AvatarTpl({Key? key, required this.entity}) : super(key: key);

  late Ask ask = BridgeHandler.askData[entity.findAttribute("PRI_QUESTION_CODE").valueString]!;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      //TODO: Icon is hardcoded, resolve this when the ask has an icon attatched
      //its hard coded on alyson too
      icon: const Icon(Icons.account_circle),
      itemBuilder: (context) {
      return List.generate(ask.childAsks.length, (index) => PopupMenuItem(
        onTap: (){
          BridgeHandler.askEvt(ask.childAsks[index]);
        },
        child: Text(ask.childAsks[index].name)));
      });
  }
}
