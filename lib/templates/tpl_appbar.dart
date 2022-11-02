import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';

class AppBarTpl extends StatelessWidget {
  final BaseEntity entity;
  // ignore: unused_field
  late final Log _log = Log(runtimeType.toString());
  AppBarTpl({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    Widget title;
    entity.baseEntityAttributes.sort(((a, b) => a.weight.compareTo(b.weight)));
    EntityAttribute logo = entity.findAttribute("PRI_LOC1");
    List<EntityAttribute> actionAttributes = entity.baseEntityAttributes.where((element) => element != logo).toList();
    title = logo.getPcmWidget();
    actionAttributes.retainWhere((element) => element.attributeCode.startsWith("PRI_LOC"));
    for (EntityAttribute attribute in actionAttributes) {
      actions.add(attribute.getPcmWidget());
    }
    return AppBar(
      title: Container(
        height: AppBar().preferredSize.height,
        child: title),
      centerTitle: false,
      actions: actions,
    );
  }
}
   