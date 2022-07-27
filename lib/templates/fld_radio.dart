import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

// class RadioField extends StatefulWidget {
//   final Ask ask;
//   late BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
//   RadioField({Key? key, required this.ask}) : super(key: key);

//   @override
//   State<RadioField> createState() => _RadioFieldState();
// }

class RadioField extends StatelessWidget {
  final Ask ask;
  late final BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
  RadioField({Key? key, required this.ask}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //thought this would be terrible but it actually works stateless
    //cool
    List<EntityAttribute> dropdownItems = [];
    BridgeHandler.beData.values.where((entity) {
      if (entity.questions.isNotEmpty) {
        return entity.questions.first.valueString == ask.questionCode;
      } else {
        dropdownItems = [EntityAttribute.create()..name = "None found"..valueString = "None Found"];
      }
      return false;
    }).forEach((entity) {
      dropdownItems.add(entity.findAttribute("PRI_NAME"));
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(title: Text(ask.question.name)),
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: dropdownItems.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                  title: Text(dropdownItems[index].valueString),
                  value: dropdownItems[index].valueString,
                  groupValue:
                      entity.findAttribute(ask.attributeCode).valueString,
                  onChanged: (_) {
                    entity.findAttribute(ask.attributeCode).valueString =
                        dropdownItems[index].valueString;
                    ask.answer(
                        entity.findAttribute(ask.attributeCode).valueString);
                  });
            }),
      ],
    );
  }
}
