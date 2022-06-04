import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

class DetailView extends StatelessWidget {
  late final BaseEntity entity;

  DetailView({required this.entity});
  @override
  Widget build(BuildContext context) {
    return Column(
        children: List.generate(entity.baseEntityAttributes.length, (index) {
      return Text(entity.baseEntityAttributes[index].valueString);
    }));
  }
}
