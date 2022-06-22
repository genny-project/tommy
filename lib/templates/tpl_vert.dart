import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/template_handler.dart';

class Vert extends StatelessWidget {
  final BaseEntity entity;
  const Vert({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(entity.baseEntityAttributes.length, (index) {
        return TemplateHandler.attributeWidget(
            entity.baseEntityAttributes[index], context);
      }),
    );
  }
}
