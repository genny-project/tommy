import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

class AppBarTpl extends AppBar {
  late final BaseEntity entity;
  final Log _log = Log("TPL_APPBARTPL");
  AppBarTpl({Key? key, required this.entity}) : super(key: key);
  Widget build(BuildContext context) {
    print("Building the actual widget");
    List<Widget> actions = [];
    Widget title = SizedBox();
    BaseEntity? root = BridgeHandler.findByCode("PCM_ROOT");
    BaseEntity? be = BridgeHandler.findByCode(
        BridgeHandler.findAttribute(root, "PRI_LOC1").valueString);
    be.baseEntityAttributes.sort(((a, b) => a.weight.compareTo(b.weight)));
    for (var attribute in be.baseEntityAttributes) {
      Ask? ask = BridgeHandler.askData[attribute.valueString];

      if (attribute.valueString.startsWith("PCM_")) {
        print("started with pcm");
        actions.add(BridgeHandler.getPcmWidget(attribute));
      } else {
        if (ask != null) {
          if (ask.childAsks.isNotEmpty) {
            List<PopupMenuEntry<String>> buttons = [];
            for (Ask ask in ask.childAsks) {
              buttons.add(PopupMenuItem(
                  value: ask.questionCode, child: Text(ask.name)));
            }
            actions.add(Container(
                height: 20,
                width: 50,
                child: PopupMenuButton<String>(
                    onSelected: (String result) {
                      BridgeHandler.evt(result);
                    },
                    itemBuilder: (BuildContext context) => buttons)));
          } else {
            title = IconButton(
              onPressed: () {
                BridgeHandler.evt(attribute.valueString);
              },
              icon: SvgPicture.network(
                "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                    (ask.question.icon),
                height: 30,
                width: 30,
              ),
            );
          }
        } else {}
      }
    }
    _log.info("Title $title");
    return AppBar(
      title: title,
      centerTitle: false,
      actions: actions,
    );
  }
}
