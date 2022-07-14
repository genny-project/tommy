import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

class AppBarTpl extends StatelessWidget {
  final BaseEntity entity;
  final Log _log = Log("TPL_APPBARTPL");
  AppBarTpl({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    Widget title;
    BaseEntity? root = BridgeHandler.findByCode("PCM_ROOT");
    BaseEntity? be = BridgeHandler.findByCode(root.findAttribute("PRI_LOC1").valueString);
    be.baseEntityAttributes.sort(((a, b) => a.weight.compareTo(b.weight)));
    EntityAttribute logo = be.findAttribute("PRI_LOC1");
    List<EntityAttribute> actionAttributes = be.baseEntityAttributes.where((element) => element != logo).toList();
    title = logo.getPcmWidget();
    for (var attribute in actionAttributes) {
      actions.add(attribute.attributeWidget());
    }
    _log.info("Title $title");
    return AppBar(
      title: title,
      centerTitle: false,
      actions: actions,
    );
  }
}
