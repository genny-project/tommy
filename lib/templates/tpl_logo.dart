import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/proto_console.dart';

class Logo extends StatelessWidget {
  final BaseEntity entity;
  const Logo({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Ask? ask = BridgeHandler
        .askData[entity.findAttribute("PRI_QUESTION_CODE").valueString];
    return ask != null
        ? TextButton(
            // iconSize: 50,
            onPressed: (() {
              BridgeHandler.askEvt(ask.childAsks[1]);
            }),
            onLongPress: (() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProtoConsole()));
            }),
            child: CachedNetworkImage(
              placeholder: (c,u)=> SizedBox(),
              placeholderFadeInDuration: Duration.zero,
              fadeInDuration: Duration.zero,
                imageUrl: BridgeHandler.getPrimary(
                        ask.childAsks[0].question.attribute.code)
                    .valueString))
        : const Text("Ask not loaded");
  }
}
