import 'package:flutter/material.dart';
import 'package:geoff/geoff.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

class CardsListView extends StatelessWidget {
  late final BaseEntity entity;
  Log _log = new Log("TPL_CARDS_LIST_VIEW");
  CardsListView({required this.entity});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: Column(
          children: List.generate(entity.baseEntityAttributes.length, (index) {
        if (entity.baseEntityAttributes[index].attributeCode
            .startsWith("PRI_LOC")) {
          return BridgeHandler.getPcmWidget(entity.baseEntityAttributes[index]);
        } else {
          return Text(entity.baseEntityAttributes[index].attribute.code.toString());
        }
      })),
    );
  }
}
