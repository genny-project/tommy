import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

//TODO: need a way to discern whether the answer count is mutually exclusive/answer limit

class DropdownField extends StatelessWidget {
  final Ask ask;
  late final BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
  late final List<BaseEntity> answers =
      parseAnswer(entity.findAttribute(ask.attributeCode).valueString);
  late final List<EntityAttribute> dropdownItems = getItems(ask);
  DropdownField({Key? key, required this.ask}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(ask.name),
      children: [
        //wrap to handle overflow
        Wrap(
          alignment: WrapAlignment.start,
          // crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5.0,
          runSpacing: 5.0,
          children: List.generate(answers.length, (index) {
            return Chip(
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  answers.removeAt(index);
                  answerDropdown();
                },
                label: Text(answers[index].name.toString()));
          }),
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
    entity.findAttribute(ask.attributeCode).valueString =
        jsonEncode(strAnswers).toString();
    ask.answer(jsonEncode(strAnswers));
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
    entity.findAttribute("PRI_NAME");
  });
  return items;
}
