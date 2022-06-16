import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/widgets/genny_container_widget.dart';

class Dashboard extends StatelessWidget {
  late final BaseEntity entity;
  final Log _log = Log("TPL_DASHBOARD");
  Dashboard({required this.entity});
  @override
  Widget build(BuildContext context) {
    return GennyContainer(
      // color: Colors.blueAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(entity.baseEntityAttributes.length, (index) {
        if (entity.baseEntityAttributes[index].attributeCode
            .startsWith("PRI_LOC")) {
          _log.info("Getting Widget for Entity ${entity.baseEntityAttributes[index].valueString}");
          return BridgeHandler.getPcmWidget(entity.baseEntityAttributes[index]);
        } else {
          return Text("Dashboard additional - ${entity.baseEntityAttributes[index].baseEntityCode.toString()}");
        }
      })),
    );
  }
}
