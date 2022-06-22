import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

class AppBarTpl extends StatelessWidget {
  final BaseEntity entity;
  final Log _log = Log("TPL_APPBARTPL");
  AppBarTpl({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    Widget title;
    BaseEntity? root = BridgeHandler.findByCode("PCM_ROOT");
    BaseEntity? be = BridgeHandler.findByCode(
        BridgeHandler.findAttribute(root, "PRI_LOC1").valueString);
    be.baseEntityAttributes.sort(((a, b) => a.weight.compareTo(b.weight)));
    EntityAttribute logo = be.baseEntityAttributes.firstWhere((element) => element.attributeCode == "PRI_LOC1");
    List<EntityAttribute> actionAttributes = be.baseEntityAttributes.where((element) => element != logo).toList();
    title = TemplateHandler.attributeWidget(logo, context);
    for (var attribute in actionAttributes) {
      actions.add(TemplateHandler.attributeWidget(attribute, context));
    }
    _log.info("Title $title");
    return AppBar(
      title: title,
      centerTitle: false,
      actions: actions,
    );
  }
}
