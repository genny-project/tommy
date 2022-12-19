import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';

class Vert extends StatelessWidget {
  final BaseEntity entity;
  const Vert({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(entity.baseEntityAttributes.length, (index) {
        return (entity.baseEntityAttributes..sort((a, b) {
         return a.attributeCode.compareTo(b.attributeCode);
        }))[index].attributeWidget();
      }),
    );
  }
}
