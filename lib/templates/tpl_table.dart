import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

class TableTpl extends StatefulWidget {
  final BaseEntity entity;

  TableTpl({Key? key, required this.entity}) : super(key: key);

  @override
  State<TableTpl> createState() => _TableTplState();
}

class _TableTplState extends State<TableTpl> {
  String? key;
  Iterable<EntityAttribute>? colBe;
  List<BaseEntity>? rowBe;
  int? tblPageSize;
  BaseEntity? searchBe;
  @override
  void initState() {
    if (searchBe == null) {
      BridgeHandler.awaitBe(widget.entity.findAttribute("PRI_LOC1").valueString)
          ?.then((value) {
        print("got searchbe value ${value.code}");
        searchBe = value;
      });
    }
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  // ignore: unused_field
  late final Log _log = Log(runtimeType.toString());
  Map<int, bool?> sort = {};

  @override
  Widget build(BuildContext context) {
    key = BridgeHandler.beData.keys.singleWhere(
        (key) =>
            key.startsWith(widget.entity.findAttribute("PRI_LOC1").valueString),
        orElse: () {
      return "";
    });

    if (key != null && key!.isNotEmpty) {
      print("using key $key");
      BaseEntity sbe = BridgeHandler.beData[key]!;
      List<BaseEntity> row = BridgeHandler.beData.values.where((element) {
        return element.parentCode == sbe.code;
      }).toList();
      int pageSize = sbe.findAttribute("SCH_PAGE_SIZE").valueInteger;
      List<EntityAttribute> col = sbe.baseEntityAttributes.where((element) {
        return element.attributeCode.startsWith("COL");
      }).toList();
      return SizedBox(
        /*Pageviews are not fond of intrinsic height. Hence the need to give it an estimated extent to render
      
      no need to give it the page length when the item count is lesser than the page size
      */
        height: row.length > pageSize
            ? (pageSize.toDouble() * 50) + 50 + 10
            : (row.length.toDouble() + 1) * 50 + 10,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                  itemCount: col.length,
                  controller: PageController(viewportFraction: 0.75),
                  itemBuilder: ((context, pageIndex) {
                    return Column(
                      children: [
                        Divider(
                          height: 5,
                        ),
                        Container(
                            height: 40,
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
                                        row.sort(((a, b) {
                                          List<BaseEntity> values = [a, b];
                                          if (!sort[pageIndex]!) {
                                            values = values.reversed.toList();
                                          }
                                          return values[0]
                                              .findAttribute(col
                                                  .elementAt(pageIndex)
                                                  .attributeCode
                                                  .replaceFirst("COL_", ""))
                                              .getValue()
                                              .compareTo(values[1]
                                                  .findAttribute(col
                                                      .elementAt(pageIndex)
                                                      .attributeCode
                                                      .replaceFirst("COL_", ""))
                                                  .getValue());
                                        }));
                                      });
                                    },
                                    // icon: Text("${sort?[pageIndex]}"))

                                    icon: sort[pageIndex] != null
                                        ? sort[pageIndex]!
                                            ? Icon(Icons.arrow_circle_up)
                                            : Icon(Icons.arrow_circle_down)
                                        : Icon(Icons.arrow_drop_down))
                              ],
                            )),
                        Divider(
                          height: 5,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                            child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: row.length,
                          itemBuilder: (context, listIndex) {
                            String value;
                            try {
                              var item = row
                                  .elementAt(listIndex)
                                  .findAttribute(col
                                      .elementAt(pageIndex)
                                      .attributeCode
                                      .replaceFirst("COL_", ""))
                                  .getValue();
                              if (item != null) {
                                value = item.toString();
                              } else {
                                throw TypeError();
                              }
                            } catch (e) {
                              print(e);
                              value = "N/A";
                            }
                            return Container(
                              height: 30,
                              color: listIndex % 2 == 0
                                  ? Colors.grey[200]
                                  : Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ))
                      ],
                    );
                  })),
            ),
          ],
        ),
      );
    } else {
      return LinearProgressIndicator();
    }
  }
}
