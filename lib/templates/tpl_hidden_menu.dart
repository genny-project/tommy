import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';

class HiddenMenu extends StatelessWidget {
  final BaseEntity entity;
  // ignore: unused_field
  final Log _log = Log("TPL_HIDDENMENU");
  HiddenMenu({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
      return const Icon(Icons.ac_unit);
  }
}
