import 'package:flutter/material.dart';
import 'package:geoff/geoff.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';

class CardsListView extends StatelessWidget {
  final BaseEntity entity;
  // ignore: unused_field
  final Log _log = Log("TPL_CARDS_LIST_VIEW");
  CardsListView({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: Column(
          children: List.generate(entity.baseEntityAttributes.length, (index) {
        if (entity.baseEntityAttributes[index].attributeCode
            .startsWith("PRI_LOC")) {
          return entity.baseEntityAttributes[index].getPcmWidget();
        } else {
          return Text(entity.baseEntityAttributes[index].attribute.code.toString());
        }
      })),
    );
  }
}
