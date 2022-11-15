import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/projectenv.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:tommy/utils/template_handler.dart';
import 'package:fixnum/fixnum.dart';

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

  //If the table screen is stuck on a linearprogressindicator, it means that this search base entity hasnt loaded
  late BaseEntity? searchBe = BridgeHandler.beData.values.singleWhereOrNull(
      (element) =>
          element.code.startsWith(widget.entity.PRI_LOC(1).valueString));

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
  late Map<int, bool?> sort = {0: null};
  late List<EntityAttribute> col =
      searchBe!.baseEntityAttributes.where((element) {
    return element.attributeCode.startsWith("COL");
  }).toList()
        ..sort(((a, b) {
          return a.weight.compareTo(b.weight);
        }));

  late int pageSize = searchBe!.findAttribute("SCH_PAGE_SIZE").valueInteger;
  int get pageStart => searchBe!.findAttribute("SCH_PAGE_START").valueInteger;
  late int totalResults =
      searchBe!.findAttribute("PRI_TOTAL_RESULTS").valueInteger;
  List<BaseEntity> getRow() {
    return (BridgeHandler.beData.values.where((element) {
      return element.parentCode == searchBe!.code;
    }).toList()
          ..sort((a, b) {
            return a.index.compareTo(b.index);
          }))
        .sublist(pageStart)
      ..sort((a, b) {
        //this ought to correct the table behaviour while allowing sort properly
        List<BaseEntity> values = [a, b];
        if (sort.values.first ?? false) {
          values = values.reversed.toList();
        }
        if (sort.values.first == null) {
          return values[0].index.compareTo(values[1].index);
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
  }

  @override
  Widget build(BuildContext context) {
    //not sure if this should be done or whether it is a hacky workaround
    //either way it prevents the app from being stuck on a loading screen forever
    searchBe = BridgeHandler.beData.values.singleWhereOrNull((element) =>
        element.code.startsWith(widget.entity.PRI_LOC(1).valueString));
    if (searchBe != null) {
      BaseEntity sbe = searchBe!;

      late List<BaseEntity> row = getRow();

      double fraction = 1 /
          ((TemplateHandler.getDeviceSize(context).width / 150)
                  .floor()
                  .clamp(1, col.length))
              .toDouble();
      String sValue = "";
      return Column(
        children: [
          //##################################################################################
          // Dummied out for the time being - must re-implement when dan's sbe work is done
          // or at least finalised
          //##################################################################################

          // Row(children: [
          //   Container(
          //     width: 200,
          //     child: TextField(onChanged: (_){
          //       sValue = _;
          //     },),
          //   ),
          //   TextButton(child: Text("search code"), onPressed: (){
          //   Ask ask = Ask.create();
          //   // Int64 int = 272 as Int64;
          //   ask.attributeCode = "PRI_SEARCH_TEXT";
          //   ask.questionCode = "QUE_SEARCH";
          //   ask.weight = 1;
          //   ask.value = "!"+sValue;
          //   ask.id = Int64.parseInt("272");
          //   ask.targetCode = sbe.code;
          //   BridgeHandler.answer(ask, ask.value);
          // },),],),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                  "${pageStart + 1} - ${min(pageStart + pageSize, pageStart + row.length)} of $totalResults"),
              IconButton(
                onPressed: pageStart != 0
                    ? () {
                        BridgeHandler.evt(
                            code: "QUE_TABLE_PREVIOUS_BTN",
                            parentCode: "QUE_TABLE_RESULTS_GRP",
                            targetCode: sbe.code);
                      }
                    : null,
                icon: Icon(Icons.chevron_left),
              ),
              IconButton(
                // the ternary operator is used here to disable the button
                // assigning null to onPressed automatically greys out the button
                // pretty nifty!
                onPressed: pageStart + pageSize < totalResults
                    ? () {
                        BridgeHandler.evt(
                            code: "QUE_TABLE_NEXT_BTN",
                            parentCode: "QUE_TABLE_RESULTS_GRP",
                            targetCode: sbe.code);
                      }
                    : null,
                icon: Icon(Icons.chevron_right),
              ),
            ],
          ),
          SizedBox(
            /*Pageviews are not fond of intrinsic height. Hence the need to give it an estimated extent to render
          no need to give it the page length when the item count is lesser than the page size
          */
            height: row.length > pageSize
                ? (pageSize.toDouble() * rowHeight) + rowHeight + 20
                : (row.length.toDouble() + 2) * rowHeight + 20,
            child: PageView.builder(
                padEnds: false,
                itemCount: col.length,
                controller: PageController(viewportFraction: fraction),
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
                          width: TemplateHandler.getDeviceSize(context).width,
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
                                      ? !sort[pageIndex]!
                                          ? const Icon(Icons.arrow_circle_up)
                                          : const Icon(Icons.arrow_circle_down)
                                      : const Icon(Icons.arrow_drop_down))
                            ],
                          )),
                      const Divider(
                        height: 5,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      row.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: min(pageSize, row.length),
                              itemBuilder: (context, listIndex) {
                                String value;
                                EntityAttribute item = row
                                    .elementAt(listIndex)
                                    .findAttribute(col
                                        .elementAt(pageIndex)
                                        .attributeCode
                                        .replaceFirst("COL_", ""));
                                Iterable<EntityAttribute> actions = sbe
                                    .baseEntityAttributes
                                    .where((element) => element.attributeCode
                                        .startsWith("ACT_"));

                                if (item.getValue() != null) {
                                  value = item.getValue().toString();
                                } else {
                                  _log.warning("Could not get value for $item");
                                  value = "N/A";
                                }
                                return Container(
                                  height: rowHeight.toDouble(),
                                  color: listIndex % 2 == 0
                                      ? Colors.grey[200]
                                      : Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      pageIndex == 0
                                          ? PopupMenuButton(
                                              icon:
                                                  const Icon(Icons.more_horiz),
                                              itemBuilder: (context) {
                                                return List.generate(
                                                    actions.length,
                                                    (index) => PopupMenuItem(
                                                        onTap: () {
                                                          BridgeHandler.evt(
                                                              code: actions
                                                                  .elementAt(
                                                                      index)
                                                                  .attributeCode,
                                                              sourceCode:
                                                                  BridgeHandler
                                                                          .getUser()!
                                                                      .code,
                                                              targetCode: item
                                                                  .baseEntityCode,
                                                              parentCode: sbe
                                                                  .parentCode,
                                                              questionCode: actions
                                                                  .elementAt(
                                                                      index)
                                                                  .attributeCode);
                                                        },
                                                        child: Text(
                                                          actions
                                                              .elementAt(index)
                                                              .attributeName,
                                                        )));
                                              })
                                          : const SizedBox(),
                                      Flexible(
                                          child: item.attribute.code ==
                                                  "PRI_IMAGE_URL"
                                              ? ClipOval(
                                                  child: CachedNetworkImage(
                                                      errorWidget: (context, e,
                                                              d) =>
                                                          const ClipOval(
                                                              child: Icon(
                                                            Icons.broken_image,
                                                            color: Colors.red,
                                                          )),
                                                      placeholder: (context,
                                                              url) =>
                                                          const ClipOval(
                                                              child: Icon(
                                                                  Icons.image)),
                                                      imageUrl:
                                                          "${ProjectEnv.baseUrl}/imageproxy/500x500,crop/${BridgeEnv.ENV_MEDIA_PROXY_URL}/$value"))
                                              : Text(
                                                  value,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                      const Icon(
                                        Icons.more_horiz,
                                        color: Colors.transparent,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ))
                          : pageStart + pageSize < row.length
                              ? const Text("No items found")
                              : LinearProgressIndicator(),
                    ],
                  );
                })),
          ),
        ],
      );
    } else {
      return const LinearProgressIndicator();
    }
  }
}
