import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

class Sidebar extends StatelessWidget {
  late final BaseEntity entity;

  Sidebar({required this.entity});
  @override
  Widget build(BuildContext context) {
    Ask ask = BridgeHandler.askData[
        BridgeHandler.findAttribute(entity, "PRI_QUESTION_CODE").valueString]!;
    EntityAttribute attribute = entity.baseEntityAttributes.firstWhere(
        (attribute) => attribute.attributeCode == "PRI_QUESTION_CODE");
    return Drawer(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: BridgeHandler
                .askData[attribute.valueString]?.question.childQuestions.length,
            // itemCount: 5,
            itemBuilder: (context, index) {
              List<QuestionQuestion>? questions = BridgeHandler
                  .askData[attribute.valueString]?.question.childQuestions;
              List<Widget> buttons = [];
              questions!.sort(((QuestionQuestion a, QuestionQuestion b) {
                return a.weight.compareTo(b.weight);
              }));
              // EntityAttribute attribute = be.baseEntityAttributes[index];
              Ask? ask = BridgeHandler.askData[questions[index].pk.targetCode];
              if (ask != null) {
                // if (ask.childAsks.isNotEmpty) {

                for (QuestionQuestion question in ask.question.childQuestions) {
                  Ask questionAsk = BridgeHandler.askData[question.pk.targetCode]!;
                  buttons.add(ListTile(
                    onTap: () {
                      BridgeHandler.evt(questionAsk.questionCode);
                      Navigator.pop(context);
                    },
                    title: Text(questionAsk.name),
                  ));
                }
                // if (ask.question.attribute.dataType.dttCode != "DTT_EVENT") {
                //   return Text(
                //       "Not event - ${ask.name} ${ask.question.attribute.dataType.dttCode}");
                // }
                return ask.childAsks.isNotEmpty
                    ? ExpansionTile(
                        leading: SizedBox(
                          width: 50,
                          child: SvgPicture.network(
                            "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
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
                            "https://internmatch-dev.gada.io/imageproxy/200x200,fit/https://internmatch-dev.gada.io/web/public/" +
                                ask.question.icon,
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
                        onTap: () {
                          BridgeHandler.evt(ask.questionCode);
                          Navigator.pop(context);
                        },
                        title: Text(ask.name + " " + ask.attributeCode + " " + questions[index].weight.toString()));
              }
              return attribute.valueString.startsWith("QUE")
                  ? ListTile(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("The ASK could not be loaded.")));
                      },
                      leading: Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      title: Text(attribute.valueString),
                    )
                  : SizedBox();
            }));
  }
}
