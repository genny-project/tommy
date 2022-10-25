import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

class Sidebar extends StatelessWidget {
  final BaseEntity entity;
  final Log _log = Log("TPL_SIDEBAR");
  Sidebar({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    EntityAttribute attribute = entity.baseEntityAttributes.firstWhere(
        (attribute) => attribute.attributeCode == "PRI_QUESTION_CODE");
    return Theme(
        data: BridgeHandler.theme,
        child: Drawer(
            key: Key(entity.code),
            child: SizedBox(
              height: 200,
              width: 200,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: BridgeHandler
                            .askData[attribute.valueString]?.childAsks.length,
                        itemBuilder: (context, index) {
                          List<Ask>? childAsks = BridgeHandler
                              .askData[attribute.valueString]!.childAsks;
                          List<Widget> buttons = [];

                          childAsks.sort(((Ask a, Ask b) {
                            return a.weight.compareTo(b.weight);
                          }));
                          Ask ask = childAsks[index];
                          Widget icon = ask.question.icon.isNotEmpty
                              ? SvgPicture.network(
                                  '${BridgeEnv.ENV_MEDIA_PROXY_URL}/${ask.question.icon}',
                                  height: 30,
                                  width: 30,
                                  color:
                                      BridgeHandler.theme.colorScheme.onPrimary,
                                  placeholderBuilder: (context) {
                                    return const Center(
                                      child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                )
                              : Center(
                                  child: Icon(
                                  Icons.circle,
                                  color:
                                      BridgeHandler.theme.colorScheme.onPrimary,
                                ));
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
                                      color: BridgeHandler
                                          .theme.colorScheme.onPrimary),
                                ),
                              ));
                            } catch (e) {
                              _log.error("Could not find question target $e");
                            }
                          }
                          return ask.childAsks.isNotEmpty
                              ?
                              //### this theme widget is necessary since the expansiontile widget doesnt let you recolour the default trailing icon
                              Theme(
                                  data: Theme.of(context).copyWith(
                                      colorScheme: Theme.of(context)
                                          .colorScheme
                                          .copyWith(
                                              primary: BridgeHandler
                                                  .theme.colorScheme.onPrimary),
                                      unselectedWidgetColor: BridgeHandler
                                          .theme.colorScheme.onPrimary),
                                  child: ExpansionTile(
                                      leading: SizedBox(width: 50, child: icon),
                                      // trailing: Icon(Icons.keyboard_arrow_down, color: BridgeHandler.theme.colorScheme.onPrimary,),
                                      title: Text(ask.name,
                                          style: TextStyle(
                                              color: BridgeHandler.theme
                                                  .colorScheme.onPrimary)),
                                      children: buttons),
                                )
                              : ListTile(
                                  leading: SizedBox(width: 50, child: icon),
                                  onTap: () {
                                    BridgeHandler.askEvt(ask);
                                    Navigator.pop(context);
                                  },
                                  title: Text(ask.name,
                                      style: TextStyle(
                                          color: BridgeHandler
                                              .theme.colorScheme.onPrimary)));
                        }),
                  )
                ],
              ),
            )));
  }
}
