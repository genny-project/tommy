import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/widgets/genny_container_widget.dart';

class Dashboard extends StatelessWidget {
  final BaseEntity entity;
  final Log _log = Log("TPL_DASHBOARD");
  Dashboard({Key? key, required this.entity}) : super(key: key);
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
          return entity.baseEntityAttributes[index].getPcmWidget();
        } else {
          return Text("Dashboard additional - ${entity.baseEntityAttributes[index].baseEntityCode.toString()}");
        }
      })),
    );
  }
}
