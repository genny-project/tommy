import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:geoff/utils/time/time_zone.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

class TimezoneTpl extends StatefulWidget {
  late final BaseEntity entity = BridgeHandler.findByCode(ask.targetCode);
  final Ask ask;
  TimezoneTpl({Key? key, required this.ask}) : super(key: key);

  @override
  State<TimezoneTpl> createState() => _TimezoneTplState();
}

class _TimezoneTplState extends State<TimezoneTpl> {
  // ignore: unused_field
  final Log _log = Log("TPL_Timezone");
  String value = "";
  @override
  void initState() {
    super.initState();
    try {
      value = widget.entity.findAttribute(widget.ask.attributeCode).valueString;
    } catch (e) {
      value;
    }
  }

  @override
  Widget build(BuildContext context) {

    TemplateHandler.contexts[widget.ask.question.code] = context;
    return ListTile(
      title: TextButton(
        child: Row(
          children: [
            Text(value.isNotEmpty ? "Time Zone: $value" : "Time Zone"),
          ],
        ),
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          showDialog(
              context: context,
              builder: ((context) {
                return SimpleDialog(
                  title: const Text("Select Time Zone"),
                  children: [
                    SizedBox(
                      height: TemplateHandler.getDeviceSize(context).width,
                      width: TemplateHandler.getDeviceSize(context).width,
                      child: ListView.builder(
                          clipBehavior: Clip.antiAlias,
                          shrinkWrap: true,
                          itemCount: Timezones.timezones.length,
                          itemBuilder: ((context, index) {
                            return ListTile(
                              title: Text(Timezones.timezones[index].text),
                              onTap: () {
                                setState(() {
                                  value = Timezones.timezones[index].utc.first;
                                });
                                widget.ask.answer(
                                    Timezones.timezones[index].utc.first);
                                Navigator.of(context).pop();
                              },
                            );
                          })),
                    )
                  ],
                );
              }));
        },
      ),
    );
  }
}
