
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
class ProcessTpl extends StatefulWidget {
  final BaseEntity entity;

  const ProcessTpl({Key? key, required this.entity}) : super(key: key);

  @override
  State<ProcessTpl> createState() => _ProcessTplState();
}

class _ProcessTplState extends State<ProcessTpl> {
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
      List<BaseEntity>? sbes = BridgeHandler.beData.values.where((element) =>
          //evil bodgery, dont like this
          //ideally the baseentity (PCM_PROCESS in this case) should just have all necessary SBEs as attributes
          //but as it stands it only gives one - and the alyson code is a little less than illuminating.
          element.code.endsWith(sbe.code.split('_').last)).toList();

      Map<String, List<BaseEntity>> items = {};
      for (BaseEntity sbe in sbes) {
        items[sbe.code] = BridgeHandler.beData.values
            .where((be) => be.parentCode == sbe.code)
            .toList();
      }
      return SizedBox(
        /*Pageviews are not fond of intrinsic height. Hence the need to give it an estimated extent to render
      no need to give it the page length when the item count is lesser than the page size
      */
        height: 9000,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.values.length,
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
                                    : pageIndex == items.values.length - 1
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
                                    sbes.elementAt(pageIndex).name,
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
                        Expanded(
                            child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items[sbes.elementAt(pageIndex).code]!.length,
                          itemBuilder: (context, listIndex) {
                            //this sort is a little different since items are displayed completely in a single
                            //column, instead of per row, hence the need to limit the column order to a single column
                            if(sort[pageIndex] == true) {
                              items[sbes.elementAt(pageIndex).code]!.sort((a, b) {
                              List<BaseEntity> values = [a, b];
                              if (!sort.values.first!) {
                                values = values.reversed.toList();
                              }
                              return values[0].name.compareTo(values[1].name);
                            });
                            }
                            
                            BaseEntity be =
                                items[sbes.elementAt(pageIndex).code]!
                                    . elementAt(listIndex);
                            List<EntityAttribute> actions = sbes.elementAt(pageIndex)
                                .baseEntityAttributes
                                .where(
                                  (element) =>
                                      element.attribute.code.startsWith("ACT_"),
                                )
                                .toList()..sort((a, b) {
                                  return a.index.compareTo(b.index);
                                },);
                            List<EntityAttribute> cols = sbe
                                .baseEntityAttributes
                                .where((attribute) =>
                                    attribute.attribute.code.startsWith("COL_"))
                                .toList();
                            Map<EntityAttribute, EntityAttribute> colValues =
                                {};
                            for (var col in cols) {
                                EntityAttribute? attribute = be.baseEntityAttributes
                                    .firstWhereOrNull((attribute) => attribute
                                        .attributeCode
                                        .endsWith(col.attribute.code
                                            .replaceFirst("COL_", "")));
                                if (attribute != null) {
                                  colValues[col] = attribute;
                                }
                              }

                            //Content display card
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Material(
                                  borderRadius: BorderRadius.circular(15),
                                  elevation: 10.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ClipOval(
                                                  child: CachedNetworkImage(
                                                      height: 50,
                                                
                                                     width: 50,
                                                      placeholder: (_, b) {
                                                        return Container(
                                                            color: BridgeHandler
                                                                    .getTheme()
                                                                .colorScheme
                                                                .primary,
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 25,
                                                              color: BridgeHandler
                                                                      .getTheme()
                                                                  .colorScheme
                                                                  .onPrimary,
                                                            ));
                                                      },
                                                      errorWidget: (context,
                                                          url, error) {
                                                        return Container(
                                                            color: BridgeHandler
                                                                    .getTheme()
                                                                .colorScheme
                                                                .primary,
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 25,
                                                              color: BridgeHandler
                                                                      .getTheme()
                                                                  .colorScheme
                                                                  .onPrimary,
                                                            ));
                                                      },
                                                      imageUrl:
                                                          "${ProjectEnv.baseUrl}/imageproxy/500x500,crop/${BridgeEnv.ENV_MEDIA_PROXY_URL}/${be.findAttribute("PRI_IMAGE_URL").valueString}")),
                                              Flexible(
                                                  child: Text(be.name)),
                                              PopupMenuButton(itemBuilder:
                                                  (BuildContext context) {
                                                return List<
                                                        PopupMenuItem>.generate(
                                                    actions.length, (index) {
                                                  return PopupMenuItem(
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
                                                            targetCode: actions
                                                                .elementAt(
                                                                    index)
                                                                .baseEntityCode,
                                                            parentCode:
                                                                sbe.parentCode,
                                                            questionCode: actions
                                                                .elementAt(
                                                                    index)
                                                                .attributeCode);
                                                      },
                                                      child: Text(actions[index]
                                                          .attributeName));
                                                });
                                              }),
                                              
                                            ],
                                          ),
                                          const Divider(),
                                          //TODO: decide on whether or not to manage visible fields locally
                                          //i.e. only display rows if they have data
                                          //at a guess i would say that the data to be shown should be denoted
                                          //by the COL_ values

                                          //present implementation just displays the values to each column it receives
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: List.generate(
                                              cols.length,
                                              (index) => Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        cols[index]
                                                            .attribute
                                                            .name,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                      ),
                                                      Text(
                                                        colValues[cols[index]]
                                                                ?.getValue()
                                                                .toString() ??
                                                            "",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                          ), Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              ClipOval(
                                                      child: CachedNetworkImage(
                                                          height:20,
                                                    
                                                         width: 20,
                                                          placeholder: (_, b) {
                                                            return Container(
                                                                color: BridgeHandler
                                                                        .getTheme()
                                                                    .colorScheme
                                                                    .primary,
                                                                child: Icon(
                                                                  Icons.person,
                                                                  size: 10,
                                                                  color: BridgeHandler
                                                                          .getTheme()
                                                                      .colorScheme
                                                                      .onPrimary,
                                                                ));
                                                          },
                                                          errorWidget: (context,
                                                              url, error) {
                                                            return Container(
                                                                color: BridgeHandler
                                                                        .getTheme()
                                                                    .colorScheme
                                                                    .primary,
                                                                child: Icon(
                                                                  Icons.person,
                                                                  size: 10,
                                                                  color: BridgeHandler
                                                                          .getTheme()
                                                                      .colorScheme
                                                                      .onPrimary,
                                                                ));
                                                          },
                                                          imageUrl:
                                                              "${ProjectEnv.baseUrl}/imageproxy/500x500,crop/${BridgeEnv.ENV_MEDIA_PROXY_URL}/${be.findAttribute("_LNK_AGENT__PRI_IMAGE_URL").valueString}")),
                                            ],
                                          ),
                                              
                                        ]),
                                  )),
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
      return const LinearProgressIndicator();
    }
  }
}
