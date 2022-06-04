import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

class Dashboard extends StatelessWidget {
  late final BaseEntity entity;
  Log _log = new Log("TPL_DASHBOARD");
  Dashboard({required this.entity});
  @override
  Widget build(BuildContext context) {
    return Column(
        children: List.generate(entity.baseEntityAttributes.length, (index) {
      if (entity.baseEntityAttributes[index].attributeCode
          .startsWith("PRI_LOC")) {
        _log.info("Getting Widget for Entity ${entity.baseEntityAttributes[index].valueString}");
        return Row(
          children: [
            Text(index.toString()),
            BridgeHandler.getPcmWidget(entity.baseEntityAttributes[index]),
          ],
        );
      } else {
        return Text(entity.baseEntityAttributes[index].baseEntityCode.toString());
      }
    }));
  }
}
