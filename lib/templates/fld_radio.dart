import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

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
    BridgeHandler.beData.values
        .where(
            (entity) => entity.questions.first.valueString == ask.questionCode)
        .forEach((entity) {
      dropdownItems.add(entity.baseEntityAttributes
          .firstWhere((element) => element.attributeCode == "PRI_NAME"));
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(title: Text(ask.question.name)),
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: dropdownItems.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                  title: Text(dropdownItems[index].valueString),
                  value: dropdownItems[index].valueString,
                  groupValue:
                      BridgeHandler.findAttribute(entity, ask.attributeCode)
                          .valueString,
                  onChanged: (_) {
                    BridgeHandler.findAttribute(entity, ask.attributeCode)
                        .valueString = dropdownItems[index].valueString;
                    BridgeHandler.answer(
                        ask,
                        BridgeHandler.findAttribute(entity, ask.attributeCode)
                            .valueString);
                  });
            }),
      ],
    );
  }
}
