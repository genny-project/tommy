import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

class TableTpl extends StatelessWidget {
  final BaseEntity entity;
  late final BaseEntity sbe = BridgeHandler.beData.values.firstWhere((be) => be.code.startsWith(entity.findAttribute("PRI_LOC1").valueString));
  late final Iterable<EntityAttribute> col =
      sbe.baseEntityAttributes.where((element) {
    return element.attributeCode.startsWith("COL");
  });
  final Log _log = Log("TPL_TABLETPL");
  late final int pageSize = sbe.findAttribute("SCH_PAGE_SIZE").valueInteger;
  TableTpl({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print("Getting sbe code ${entity.findAttribute("PRI_LOC1").valueString}");
    print("page size ${sbe.baseEntityAttributes.length} $pageSize ${sbe.findAttribute("SCH_PAGE_SIZE").valueInteger}");
    return Container(
      // height: MediaQuery.of(context).size.height,
      height: (sbe.findAttribute("SCH_PAGE_SIZE").valueInteger.toDouble() * 30) + 50 + 10,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
                itemCount: col.length,
                controller: PageController(viewportFraction: 0.75),
                itemBuilder: ((context, index) {
                  return Container(
                    // padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.grey[350],
                                borderRadius: index == 0
                                    ? const BorderRadius.horizontal(
                                        left: Radius.circular(20))
                                    : index == col.length - 1
                                        ? const BorderRadius.horizontal(
                                            right: Radius.circular(20))
                                        : BorderRadius.zero),
                            width: MediaQuery.of(context).size.width,
                            child: Text(col.elementAt(index).attributeName)),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.grey[350],
                            width: MediaQuery.of(context).size.width,
                          ),
                        )
                      ],
                    ),
                  );
                })),
          ),
        ],
      ),
    );
  }
}
