import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/bridge_handler.dart';

class HiddenMenu extends StatelessWidget {
  late final BaseEntity entity;
  final Log _log = Log("TPL_HIDDENMENU");
  HiddenMenu({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
      return Icon(Icons.ac_unit);
  }
}
