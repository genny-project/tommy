import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/projectenv.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:tommy/widget_book/widgetbook.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tommy/utils/template_handler.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook/src/workbench/workbench_provider.dart';


class ProcessTpl extends StatefulWidget {
  final BaseEntity entity;

  const ProcessTpl({Key? key, required this.entity}) : super(key: key);

  @override
  State<ProcessTpl> createState() => _ProcessTplState();
}

class _ProcessTplState<CustomTheme> extends State<ProcessTpl> {
  String? key;
  Iterable<EntityAttribute>? colBe;
  List<BaseEntity>? rowBe;
  int? tblPageSize;

  int rowHeight = 40;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ignore: unused_field
  late final Log _log = Log(runtimeType.toString());
  Map<int, bool?> sort = {0: false};

  @override
  Widget build(BuildContext context) {
    BaseEntity? sbe = BridgeHandler.beData.values.firstWhereOrNull((element) =>
        element.code.startsWith(widget.entity.PRI_LOC(1).valueString));
    if (sbe != null) {
      List<BaseEntity>? sbes = widget.entity.baseEntityAttributes.where(
        (beAttribute) {
          return beAttribute.attributeCode.startsWith("PRI_LOC");
        },
      )
      .sorted((a, b) => a.weight.compareTo(b.weight))
      .map((e) {
        return BridgeHandler.findByCode(e.valueString);
      }).toList();

      Map<String, List<BaseEntity>> items = {};
      for (BaseEntity sbe in sbes) {
        items[sbe.code] = BridgeHandler.beData.values
            .where((be) => be.parentCode == sbe.code)
            .toList();
      }
      // return Text("${sbes.map((e) => e.code).toString()}");
      double fraction = 1 /
          ((TemplateHandler.getDeviceSize(context).width / 300)
                  .floor()
                  .clamp(1, sbes.length))
              .toDouble();
      return GestureDetector(
        onVerticalDragUpdate: (_) {},
        child: SizedBox(
            /*Pageviews are not fond of intrinsic height. Hence the need to give it an estimated extent to render
        no need to give it the page length when the item count is lesser than the page size
        */
            height: TemplateHandler.getDeviceSize(context).height - (
                Scaffold.of(context).appBarMaxHeight ?? 0),
            child: PageView.builder(
                padEnds: false,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: sbes.length,
                controller: PageController(viewportFraction: fraction),
                itemBuilder: ((context, pageIndex) {
                  return TemplateHandler.getTemplate(
                      sbes
                          .elementAt(pageIndex)
                          .findAttribute("PRI_TEMPLATE_CODE")
                          .valueString,
                      sbes.elementAt(pageIndex));
                }))),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}
