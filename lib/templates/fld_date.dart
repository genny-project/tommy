import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

class DateTemplate extends StatelessWidget {
  final Ask ask;
  late final BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
  DateTemplate({Key? key, required this.ask}) : super(key: key);  
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: ((context, setState) => ListTile(
            contentPadding: ask.mandatory ? const EdgeInsets.symmetric(horizontal: 16).copyWith(left: 12) : null,
            shape: ask.mandatory ? const Border(left: BorderSide(color: Colors.red, width: 4)) : null,
            leading: const Icon(Icons.calendar_month),
            trailing: Text(entity.findAttribute(ask.attributeCode).valueDate),
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(entity
                              .findAttribute(ask.attributeCode)
                              .valueDate) ??
                          DateTime.now(),
                      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                      lastDate: DateTime.utc(DateTime.now().year + 100))
                  .then((date) {
                setState((() {
                  entity.findAttribute(ask.attributeCode).valueDate =
                      DateFormat('y-M-d').format(date!);
                }));

                ask.answer(DateFormat('y-M-d').format(date!));
              });
            },
            title: Text(ask.name))
            ));
  }
}
