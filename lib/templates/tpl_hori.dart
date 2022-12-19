import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';

class Hori extends StatelessWidget {
  final BaseEntity entity;
  const Hori({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<EntityAttribute> priLocs = entity.baseEntityAttributes.where((element) => element.attributeCode.startsWith('PRI_LOC')).toList();
    return Row(children: List.generate(entity.baseEntityAttributes.length, (index) {
      return entity.baseEntityAttributes[index].attributeWidget();
    }),);
  }
}
