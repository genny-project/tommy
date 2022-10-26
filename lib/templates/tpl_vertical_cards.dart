import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/projectenv.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class VerticalCardsTpl extends StatelessWidget {
  final BaseEntity entity;
  VerticalCardsTpl({Key? key, required this.entity}) : super(key: key);

  late BaseEntity? sbe = BridgeHandler.beData.values.firstWhereOrNull((element) =>
        element.code.startsWith(entity.PRI_LOC(1).valueString));
  late List<BaseEntity>? entries = BridgeHandler.beData.values.where((element) => element.parentCode == sbe!.code).toList();
  late List<EntityAttribute> actions = sbe!
      .baseEntityAttributes
      .where(
        (element) => element.attribute.code.startsWith("ACT_"),
      )
      .toList()
    ..sort(
      (a, b) {
        return a.index.compareTo(b.index);
      },
    );
  Map<int, bool?> sort = {0: false};
  @override
  Widget build(BuildContext context) {
    if(sbe != null) {
    return SizedBox(
        child: Column(children: [
          const Divider(
            height: 5,
          ),
          Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Center(
                      child: Text(
                        sbe!.name,
                        style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )),
          const Divider(
            height: 1,
          ),
          Flexible(
            
              child: ShaderMask(
      blendMode: BlendMode.dstOut,
            shaderCallback: (Rect rect) {
              return LinearGradient(
                
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0,0.065],
                colors: [Colors.white.withOpacity(1), Colors.transparent]).createShader(rect);
            },
      child: ListView.builder(
                
                clipBehavior: Clip.antiAlias,
                  itemCount: entries!.length,
                  itemBuilder: (context, listIndex) {
                    BaseEntity be = entries![listIndex];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                          borderRadius: BorderRadius.circular(15),
                          elevation: 10.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClipOval(
                                          child: CachedNetworkImage(
                                              height: 50,
                                              width: 50,
                                              placeholder: (_, b) {
                                                return Container(
                                                    color: BridgeHandler.theme
                                                        .colorScheme
                                                        .primary,
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 25,
                                                      color: BridgeHandler.theme
                                                          .colorScheme
                                                          .onPrimary,
                                                    ));
                                              },
                                              errorWidget: (context, url, error) {
                                                return Container(
                                                    color: BridgeHandler.theme
                                                        .colorScheme
                                                        .primary,
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 25,
                                                      color: BridgeHandler.theme
                                                          .colorScheme
                                                          .onPrimary,
                                                    ));
                                              },
                                              imageUrl: "${ProjectEnv.baseUrl}/imageproxy/500x500,crop/${BridgeEnv.ENV_MEDIA_PROXY_URL}/${be.findAttribute("PRI_IMAGE_URL").valueString}"
                                              )),
                                      Flexible(child: Text(be.name)),
                                      PopupMenuButton(
                                          // padding: EdgeInsets.zero,
                                          itemBuilder: (BuildContext context) {
                                        return List<PopupMenuItem>.generate(
                                            actions.length, (index) {
                                          return PopupMenuItem(
                                              onTap: () {
                                                BridgeHandler.evt(
                                                    code: actions
                                                        .elementAt(index)
                                                        .attributeCode,
                                                    sourceCode:
                                                        BridgeHandler.getUser()!.code,
                                                    targetCode: actions
                                                        .elementAt(index)
                                                        .baseEntityCode,
                                                    parentCode: sbe!.parentCode,
                                                    questionCode: actions
                                                        .elementAt(index)
                                                        .attributeCode);
                                              },
                                              child:
                                                  Text(actions[index].attributeName));
                                        });
                                      }),
                                    ],
                                  ),
                                  const Divider(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      be.baseEntityAttributes.length,
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
                                                be.baseEntityAttributes[index]
                                                    .attribute
                                                    .name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                              Text(
                                                be.baseEntityAttributes[index]
                                                        .getValue()
                                                        .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ]),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ClipOval(
                                          child: CachedNetworkImage(
                                              height: 20,
                                              width: 20,
                                              placeholder: (_, b) {
                                                return Container(
                                                    color: BridgeHandler.theme
                                                        .colorScheme
                                                        .primary,
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 10,
                                                      color: BridgeHandler.theme
                                                          .colorScheme
                                                          .onPrimary,
                                                    ));
                                              },
                                              errorWidget: (context, url, error) {
                                                return Container(
                                                    color: BridgeHandler.theme
                                                        .colorScheme
                                                        .primary,
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 10,
                                                      color: BridgeHandler.theme
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
                  }),
            ),
          )
        ]),
    ); } else {
      return SizedBox(
        height: 5,
        child: Center(child: CircularProgressIndicator()));
    }
  }
}
