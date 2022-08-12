import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

class DetailView extends StatelessWidget {
  final BaseEntity entity;
  const DetailView({Key? key, required this.entity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    entity.baseEntityAttributes.sort(
      (a, b) {
        return a.weight.compareTo(b.weight);
      },
    );

    BaseEntity? sbe =
        BridgeHandler.beData[entity.findAttribute("PRI_LOC1").valueString];
    if (sbe != null) {
      BaseEntity displayEntity =
          BridgeHandler.beData.values.singleWhere((element) {
        return element.parentCode == sbe.code;
      })
            ..baseEntityAttributes.sort((a, b) => a.weight.compareTo(b.weight));
      List<EntityAttribute> attributes = displayEntity.baseEntityAttributes
          .where((attribute) => !attribute.attributeCode.startsWith("_"))
          .toList();
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        // color: Colors.greenAccent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        displayEntity.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    )
                  ] +
                  [ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: attributes.length,
                    separatorBuilder: ((context, index) {
                      return const Divider();
                    }),
                    itemBuilder: ((context, index) {
                    EntityAttribute attribute = attributes[index];
                    // return Text(attribute.description);
                    // return Text(attribute.attributeName + attribute.getValue().toString());
                    String value = attribute.attributeCode;
                    if (value.startsWith('PRI_')) {
                      return IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(attribute.attributeName.toString()), 
                            Text(attribute.getValue().toString()),
                          ],
                        ),
                      );
                    } else if (TemplateHandler.fixLnkAndPri(
                            attribute.attributeCode)
                        .startsWith("LNK")) {
                      // List<EntityAttribute> lnkAttributes = displayEntity.baseEntityAttributes.where().toList();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(attribute.attributeName.toString()),
                          Text(displayEntity.baseEntityAttributes
                              .singleWhere((element) =>
                                  TemplateHandler.fixLnkAndPri(
                                          element.attributeCode)
                                      .startsWith(attribute.attributeCode))
                              .getValue()
                              .toString())
                        ],
                      );
                    }
                    return Text(attribute.attributeCode);
                  }),)])
        ),
      );
    }
    return const LinearProgressIndicator();
  }
}
