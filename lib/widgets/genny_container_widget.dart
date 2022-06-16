import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:geoff/utils/timezones.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

class GennyContainer extends StatelessWidget {
  Widget child;
  double? width;
  double? height;
  GennyContainer({required this.child, this.width, this.height, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[350],
        border: Border.all(color: Colors.black, width: 4.0)
        // color: Color.fromARGB(255, Random().nextInt(255), Random().nextInt(255), Random().nextInt(255)),
      ),
      width: width,
      height: height,
      child: child,
    );
  }
}
