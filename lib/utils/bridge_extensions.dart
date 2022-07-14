import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

extension BaseEntityExtension on BaseEntity {
  EntityAttribute findAttribute(String attributeName) {
    return BridgeHandler.findAttribute(this, attributeName);
  }
}

extension EntityAttributeExtension on EntityAttribute {
  Widget getPcmWidget() {
    return BridgeHandler.getPcmWidget(this);
  }

  Widget attributeWidget() {
    return TemplateHandler.attributeWidget(this);
  }
}

extension AskExtension on Ask {
  void answer(dynamic value) {
    BridgeHandler.answer(this, value);
  }
}