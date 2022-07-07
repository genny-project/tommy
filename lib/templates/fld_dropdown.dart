import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

//TODO: need a way to discern whether the answer count is mutually exclusive/answer limit

class DropdownField extends StatelessWidget {
  final Ask ask;
  late final BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
  late final List<BaseEntity> answers = parseAnswer(
      BridgeHandler.findAttribute(entity, ask.attributeCode).valueString);
  late final List<EntityAttribute> dropdownItems = getItems(ask);
  DropdownField({Key? key, required this.ask}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(ask.name),
      children: [
        //wrap to handle overflow
        Wrap(
          spacing: 5.0,
          runSpacing: 5.0,
          children: List.generate(
              answers.length,
              (index) => Container(
                  decoration: BoxDecoration(
                      color: BridgeHandler.getTheme().colorScheme.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(90))),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        answers[index].name.toString(),
                        style: TextStyle(
                            color:
                                BridgeHandler.getTheme().colorScheme.onPrimary),
                      ),
                      IconButton(
                        onPressed: () {
                          answers.removeAt(index);
                          answerDropdown();
                        },
                        icon: const Icon(Icons.close),
                        color: BridgeHandler.getTheme().colorScheme.onPrimary,
                        padding: const EdgeInsets.all(3),
                        iconSize: 20.0,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ))),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dropdownItems.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
                onTap: () {
                  answers.add(BridgeHandler
                      .beData[dropdownItems[index].baseEntityCode]!);
                  answerDropdown();
                },
                title: Text(BridgeHandler
                    .beData[dropdownItems[index].baseEntityCode]!.name));
          },
        ),
      ],
    );
  }

  void answerDropdown() {
    List<String> strAnswers =
        List.generate(answers.length, (index) => answers[index].code);
    BridgeHandler.findAttribute(entity, ask.attributeCode).valueString =
        jsonEncode(strAnswers).toString();
    BridgeHandler.answer(ask, jsonEncode(strAnswers));
  }
}

//function to create a list of baseentities from the codes returned from the dropdown answer
List<BaseEntity> parseAnswer(String answer) {
  if (answer == "") {
    return [];
  }
  List answers = jsonDecode(answer);
  List<BaseEntity> answerEntities = [];
  for (var answer in answers) {
    {
      answerEntities.add(BridgeHandler.beData[answer]!);
    }
  }
  return answerEntities;
}

List<EntityAttribute> getItems(Ask ask) {
  List<EntityAttribute> items = [];
  BridgeHandler.beData.values
      .where((entity) => entity.questions.first.valueString == ask.questionCode)
      .forEach((entity) {
    items.add(entity.baseEntityAttributes
        .firstWhere((element) => element.attributeCode == "PRI_NAME"));
  });
  return items;
}
