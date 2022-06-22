import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';
import 'package:tommy/widgets/genny_container_widget.dart';

class DetailView extends StatelessWidget {
  final BaseEntity entity;
  const DetailView({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    entity.baseEntityAttributes.sort((a, b) {
      return a.weight.compareTo(b.weight);
    },);
    return GennyContainer(
      width: MediaQuery.of(context).size.width * 0.9,
      // color: Colors.greenAccent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entity.baseEntityAttributes.length, (index) {
          EntityAttribute attribute = entity.baseEntityAttributes[index];
          String value = attribute.valueString;
          // return Text(attribute.description);
          if(value.startsWith('PRI_')){
            EntityAttribute priAttribute = BridgeHandler.findAttribute(BridgeHandler.getUser()!,value);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(priAttribute.attribute.name.toString()),
                Text(priAttribute.valueString.toString()),
              ],
            );
          } else if(value.startsWith("_LNK")) {
            EntityAttribute lnkAttribute = BridgeHandler.findAttribute(BridgeHandler.getUser()!, TemplateHandler.fixLnkAndPri(value));
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lnkAttribute.attribute.name.toString()),
                Text(lnkAttribute.valueString)
              ],
            );
          }
          return Text(attribute.valueString);
        })),
      ),
    );
  }
}
