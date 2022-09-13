import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

class HorizontalCardsTpl extends StatelessWidget {
  final BaseEntity entity;
  late final BaseEntity sbe = BridgeHandler.beData[entity.PRI_LOC(1).valueString]!;
  HorizontalCardsTpl({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(entity.baseEntityAttributes.length, (index) {
        return Text(entity.PRI_LOC(1).valueString.toString());
      }),
    );
  }
}
