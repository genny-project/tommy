import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:collection/collection.dart';

class TableTpl extends StatefulWidget {
  final BaseEntity entity;

  const TableTpl({Key? key, required this.entity}) : super(key: key);

  @override
  State<TableTpl> createState() => _TableTplState();
}

class _TableTplState extends State<TableTpl> {
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
    BaseEntity? sbe = BridgeHandler.beData.values.singleWhereOrNull((element) =>
        element.code
            .startsWith(widget.entity.PRI_LOC(1).valueString));

    if (sbe != null) {
      List<EntityAttribute> col = sbe.baseEntityAttributes.where((element) {
        return element.attributeCode.startsWith("COL");
      }).toList();
      late List<BaseEntity> row = BridgeHandler.beData.values.where((element) {
        return element.parentCode == sbe.code;
      }).toList()
        ..sort((a, b) {
          //this ought to correct the table behaviour while allowing sort properly
          List<BaseEntity> values = [a, b];
          if (!sort.values.first!) {
            values = values.reversed.toList();
          }
          return values[0]
              .findAttribute(col
                  .elementAt(sort.keys.first)
                  .attributeCode
                  .replaceFirst("COL_", ""))
              .getValue()
              .compareTo(values[1]
                  .findAttribute(col
                      .elementAt(sort.keys.first)
                      .attributeCode
                      .replaceFirst("COL_", ""))
                  .getValue());
        });
      int pageSize = sbe.findAttribute("SCH_PAGE_SIZE").valueInteger;

      return SizedBox(
        /*Pageviews are not fond of intrinsic height. Hence the need to give it an estimated extent to render
      no need to give it the page length when the item count is lesser than the page size
      */
        height: row.length > pageSize
            ? (pageSize.toDouble() * rowHeight) + rowHeight + 20
            : (row.length.toDouble() + 2) * rowHeight + 20,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                  itemCount: col.length,
                  controller: PageController(viewportFraction: 0.75),
                  itemBuilder: ((context, pageIndex) {
              
                    return Column(
                      children: [
                        const Divider(
                          height: 5,
                        ),
                        Container(
                            height: rowHeight.toDouble(),
                            decoration: BoxDecoration(
                                borderRadius: pageIndex == 0
                                    ? const BorderRadius.horizontal(
                                        left: Radius.circular(20))
                                    : pageIndex == col.length - 1
                                        ? const BorderRadius.horizontal(
                                            right: Radius.circular(20))
                                        : BorderRadius.zero),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    col.elementAt(pageIndex).attributeName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        sort = {
                                          pageIndex: !(sort[pageIndex] ?? false)
                                        };
                                      });
                                    },
                                    // icon: Text("${sort?[pageIndex]}"))

                                    icon: sort[pageIndex] != null
                                        ? sort[pageIndex]!
                                            ? const Icon(Icons.arrow_circle_up)
                                            : const Icon(
                                                Icons.arrow_circle_down)
                                        : const Icon(Icons.arrow_drop_down))
                              ],
                            )),
                        const Divider(
                          height: 5,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        row.isNotEmpty ? Expanded(
                            child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: row.length,
                          itemBuilder: (context, listIndex) {
                                  
                            String value;
                            EntityAttribute item = row
                                .elementAt(listIndex)
                                .findAttribute(col
                                    .elementAt(pageIndex)
                                    .attributeCode
                                    .replaceFirst("COL_", ""));
                            Iterable<EntityAttribute> actions =
                                sbe.baseEntityAttributes.where((element) =>
                                    element.attributeCode.startsWith("ACT_"));
                            try {
                              if (item.getValue() != null) {
                                value = item.getValue().toString();
                              } else {
                                throw TypeError();
                              }
                            } catch (e) {
                              _log.error(e);
                              value = "N/A";
                            }
                            return Container(
                              height: rowHeight.toDouble(),
                              color: listIndex % 2 == 0
                                  ? Colors.grey[200]
                                  : Colors.transparent,
                              child: pageIndex != 0 ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      value,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ) : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  PopupMenuButton(
                                          icon: const Icon(Icons.more_horiz),
                                          itemBuilder: (context) {
                                            return List.generate(
                                                actions.length,
                                                (index) => PopupMenuItem(
                                                    onTap: () {
                                                      BridgeHandler.evt(
                                                          code: actions
                                                              .elementAt(index)
                                                              .attributeCode,
                                                          sourceCode: BridgeHandler
                                                                  .getUser()!
                                                              .code,
                                                          targetCode: item
                                                              .baseEntityCode,
                                                          parentCode:
                                                              sbe.parentCode,
                                                          questionCode:
                                                              actions
                                                        .elementAt(index)
                                                        .attributeCode);
                                                    },
                                                    child: Text(actions
                                                        .elementAt(index)
                                                        .attributeName,)));
                                          }),
                                          Flexible(child: Text(value, overflow: TextOverflow.ellipsis,)),
                                          const Icon(Icons.more_horiz, color: Colors.transparent,)
                              ],)
                            );
                          },
                        )) : 
                      const Text("No items found")
                  
                      ],
                    );
                  })),
            ),
          ],
        ),
      );
    } else {
      return const LinearProgressIndicator();
    }
  }
}
