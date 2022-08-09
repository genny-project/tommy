import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

class ActionButtonTpl extends StatelessWidget {
  // TODO: sort this out once this is a PCM
  final EntityAttribute attribute;
  late final Ask? ask = BridgeHandler.askData[attribute.valueString];
  // ignore: unused_field
  late final Log _log = Log(runtimeType.toString());
  ActionButtonTpl({Key? key, required this.attribute}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(itemBuilder: (context) {
      return List.generate(ask?.childAsks.length ?? 0, (index) => PopupMenuItem(
        onTap: (){
          BridgeHandler.evt(ask!.childAsks[index]);
        },
        child: Text(ask!.childAsks[index].name)));
      });
  }
}
