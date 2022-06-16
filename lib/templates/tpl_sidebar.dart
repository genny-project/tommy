import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/bridge_handler.dart';

class Sidebar extends StatelessWidget {
  late final BaseEntity entity;
  final Log _log = Log("TPL_SIDEBAR");
  Sidebar({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Ask ask = BridgeHandler.askData[
        BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString]!;
    EntityAttribute attribute = entity.baseEntityAttributes.firstWhere(
        (attribute) => attribute.attributeCode == "PRI_QUESTION_CODE");
    print("Attribute ${ask.childAsks.length}");
    return Drawer(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount:
                BridgeHandler.askData[attribute.valueString]?.childAsks.length,
            itemBuilder: (context, index) {
              List<Ask>? childAsks =
                  BridgeHandler.askData[attribute.valueString]?.childAsks;
              List<Widget> buttons = [];

              childAsks!.sort(((Ask a, Ask b) {
                return a.weight.compareTo(b.weight);
              }));
              // Ask? ask = BridgeHandler.askData[[index].targetCode];
              Ask? ask = childAsks[index];
              print("Ask child asks ${ask.childAsks.length}");
              if (ask != null) {
                for (Ask ask in ask.childAsks) {
                  try {
                    // Ask questionAsk =
                    //     BridgeHandler.askData[ask.targetCode]!;
                    buttons.add(ListTile(
                      onTap: () {
                        BridgeHandler.evt(ask.questionCode);
                        Navigator.pop(context);
                      },
                      title: Text(ask.name),
                    ));
                  } catch (e) {
                    _log.error("Could not find question target $e");
                  }
                }
                print(
                    "Image url ${BridgeEnv.ENV_MEDIA_PROXY_URL + '/' + (ask.question.icon)}");
                print("Child Asks ${ask.childAsks}");
                return ask.childAsks.isNotEmpty
                    ? ExpansionTile(
                        leading: SizedBox(
                          width: 50,
                          child: SvgPicture.network(
                            BridgeEnv.ENV_MEDIA_PROXY_URL +
                                '/' +
                                (ask.question.icon),
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
                        title: Text(ask.name),
                        children: buttons,
                      )
                    : ListTile(
                        // style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        leading: Container(
                          width: 50,
                          child: SvgPicture.network(
                            BridgeEnv.ENV_MEDIA_PROXY_URL +
                                '/' +
                                ask.question.icon,
                            height: 30,
                            width: 30,
                            color: Colors.orange,
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
                          BridgeHandler.evt(ask.questionCode);
                          Navigator.pop(context);
                        },
                        title: Text(ask.name));
              }
              return attribute.valueString.startsWith("QUE")
                  ? ListTile(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("The ASK could not be loaded.")));
                      },
                      leading: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      title: Text(attribute.valueString),
                    )
                  : SizedBox();
            }));
  }
}
