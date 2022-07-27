import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

class TableTpl extends StatelessWidget {
  final BaseEntity entity;
  late final BaseEntity sbe = BridgeHandler.beData.values.firstWhere(
      (be) => be.code.startsWith(entity.findAttribute("PRI_LOC1").valueString), orElse: (){
        return BaseEntity.create();
      })
    ..baseEntityAttributes.sort(((a, b) => a.weight.compareTo(b.weight)));
  late final Iterable<EntityAttribute> col =
      sbe.baseEntityAttributes.where((element) {
    return element.attributeCode.startsWith("COL");
  });
  late final Iterable<BaseEntity> row =
      BridgeHandler.beData.values.where((element) {
    return element.parentCode == sbe.code;
  });
  final Log _log = Log("TPL_TABLETPL");
  late final int pageSize = sbe.findAttribute("SCH_PAGE_SIZE").valueInteger;
  TableTpl({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print("Attribute codes - ${sbe.baseEntityAttributes.map((e) => e.attributeCode)}");
    print("Getting sbe code ${entity.findAttribute("PRI_LOC1").valueString}");
    print("page size ${sbe.baseEntityAttributes.length} $pageSize ${sbe.findAttribute("SCH_PAGE_SIZE").valueInteger}");
    return Container(
      /*Pageviews are not fond of intrinsic height. Hence the need to give it an estimated extent to render*/
      height:
          (sbe.findAttribute("SCH_PAGE_SIZE").valueInteger.toDouble() * 50) +
              50 +
              10,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
                itemCount: col.length,
                controller: PageController(viewportFraction: 0.75),
                itemBuilder: ((context, pageIndex) {
                  return Column(
                    children: [
                      Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.grey[350],
                              borderRadius: pageIndex == 0
                                  ? const BorderRadius.horizontal(
                                      left: Radius.circular(20))
                                  : pageIndex == col.length - 1
                                      ? const BorderRadius.horizontal(
                                          right: Radius.circular(20))
                                      : BorderRadius.zero),
                          width: MediaQuery.of(context).size.width,
                          child:
                              Center(child: Text(col.elementAt(pageIndex).attributeName, style: TextStyle(fontWeight: FontWeight.bold),),)),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                          child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: row.length,
                        itemBuilder: (context, listIndex) {
                          String value;
                          try {
                            value = row
                                .elementAt(listIndex)
                                .findAttribute(col
                                    .elementAt(pageIndex)
                                    .attributeCode
                                    .substring(4))
                                .valueString;
                          } catch (e) {
                            value = "N/A";
                          }
                          return Container(
                            height: 30,
                            color: listIndex % 2 == 0 ? Colors.grey[200] : Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(value),
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
  }
}
