import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:geoff/utils/timezones.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/qdataaskmessage.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

class TimezoneWidget extends StatefulWidget {
  late final BaseEntity entity;
  Ask ask;
  TimezoneWidget({required this.entity, required this.ask});

  @override
  State<TimezoneWidget> createState() => _TimezoneWidgetState();
}

class _TimezoneWidgetState extends State<TimezoneWidget> {
  final Log _log = Log("TPL_Timezone");
  String value = "";
  @override
  void initState() {
    super.initState();
    try {
      value =
          BridgeHandler.findAttribute(widget.entity, widget.ask.attributeCode)
              .valueString;
    } catch (e) {
      value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextButton(
        child: Row(
          children: [
            Text(value.length > 0 ? "Time Zone: ${value}" : "Time Zone"),
          ],
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: ((context) {
                return SimpleDialog(
                  title: Text("Select Time Zone"),
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width,
                      width: MediaQuery.of(context).size.width,
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
                                // state((){
                                //   value = "r";
                                // });
                                BridgeHandler.answer(widget.ask,
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
