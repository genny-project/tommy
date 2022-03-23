import 'package:flutter/material.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/projectenv.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BridgeHandler {
  static Drawer createDrawer(Ask ask) {
    Column content = Column(
      children: [Text("Column")],
    );
    Drawer drawer = Drawer(
      child: content,
    );
    for (Ask ask in ask.childAsks) {
      content.children.add(TextButton(
        child: Row(
          children: [
            SvgPicture.network(
                "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                    ask.question.icon, height: 30, width: 30,),
            Text(ask.name),
          ],
        ),
        onPressed: () {},
      ));
    }
    return drawer;
  }
}
