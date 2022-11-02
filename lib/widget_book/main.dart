import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'widgetbook.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/ask.pb.dart';

void main(List<String> args) {
  print(Directory.current);
  String file = File("lib/widget_book/backup.json").readAsStringSync();
  Map<String,dynamic> json = jsonDecode(file);
  (json["be"] as List<dynamic>).forEach((string) {
    BaseEntity be = BaseEntity.fromJson(jsonEncode(jsonDecode(string)));
    BridgeHandler.beData[be.code] = be;
  },);
  (json["ask"] as List<dynamic>).forEach((string) {
    Ask ask = Ask.fromJson(jsonEncode(jsonDecode(string)));
    BridgeHandler.askData[ask.question.code] = ask;
  });
  BridgeEnv.map.forEach((key, value) {
    print("Key item ${json['env'][key]}");
    if (json['env'].containsKey(key)) {
    BridgeEnv.map[key]!(json["env"][key]);
    }
  },);
  // BridgeHandler.beData = beData;
  // BridgeHandler.askData = askData;
  runApp(WidgetbookHotReload(file));
}