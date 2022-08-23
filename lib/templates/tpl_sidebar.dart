import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/proto_console.dart';

class Sidebar extends StatelessWidget {
  final BaseEntity entity;
  final Log _log = Log("TPL_SIDEBAR");
  Sidebar({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    EntityAttribute attribute = entity.baseEntityAttributes.firstWhere(
        (attribute) => attribute.attributeCode == "PRI_QUESTION_CODE");
    return Theme(
      data: BridgeHandler.getTheme(),
      child: Drawer(
          key: Key(entity.code),
          child: Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: BridgeHandler
                      .askData[attribute.valueString]?.childAsks.length,
                  itemBuilder: (context, index) {
                    List<Ask>? childAsks =
                        BridgeHandler.askData[attribute.valueString]!.childAsks;
                    List<Widget> buttons = [];

                    childAsks.sort(((Ask a, Ask b) {
                      return a.weight.compareTo(b.weight);
                    }));
                    Ask ask = childAsks[index];
                    for (Ask ask in ask.childAsks) {
                      try {
                        buttons.add(ListTile(
                          onTap: () {
                            BridgeHandler.askEvt(ask);
                            Navigator.pop(context);
                          },
                          title: Text(
                            ask.name,
                            style: TextStyle(
                                color:
                                    BridgeHandler.getTheme().colorScheme.primary),
                          ),
                        ));
                      } catch (e) {
                        _log.error("Could not find question target $e");
                      }
                    }
                    return ask.childAsks.isNotEmpty
                        ? ExpansionTile(
                            leading: SizedBox(
                              width: 50,
                              child: SvgPicture.network(
                                '${BridgeEnv.ENV_MEDIA_PROXY_URL}/${ask.question.icon}',
                                height: 30,
                                width: 30,
                                placeholderBuilder: (context) {
                                  return const Center(
                                    child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator()),
                                  );
                                },
                              ),
                            ),
                            title: Text(ask.name,
                                style: TextStyle(
                                    color: BridgeHandler.getTheme()
                                        .colorScheme
                                        .primary)),
                            children: buttons
                          
                          )
                        : Tooltip(
                            message: ask.questionCode,
                            child: ListTile(
                                leading: SizedBox(
                                  width: 50,
                                  child: SvgPicture.network(
                                    '${BridgeEnv.ENV_MEDIA_PROXY_URL}/${ask.question.icon}',
                                    height: 30,
                                    width: 30,
                                    color: BridgeHandler.getTheme()
                                        .colorScheme
                                        .onPrimary,
                                    placeholderBuilder: (context) {
                                      return const Center(
                                        child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: CircularProgressIndicator()),
                                      );
                                    },
                                  ),
                                ),
                                onTap: () {
                                  BridgeHandler.askEvt(ask);
                                  Navigator.pop(context);
                                },
                                title: Text(ask.name,
                                    style: TextStyle(
                                        color: BridgeHandler.getTheme()
                                            .colorScheme
                                            .onPrimary))),
                          );
                  }),
                  IconButton(
                    color: Colors.transparent,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const ProtoConsole()));
                              },
                              icon: const Icon(Icons.abc))
            ],
          ))
    );
  }
}
