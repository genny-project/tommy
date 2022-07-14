import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';

class Radio extends StatelessWidget {
  final BaseEntity entity;
  const Radio({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(entity.baseEntityAttributes.length, (index) {
        return Text(entity.baseEntityAttributes.toString());
      }),
    );
  }
}
