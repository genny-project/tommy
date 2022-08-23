import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

/*Going to make this stateful. It works in stateless, but the latency then subsequent jarring update
looks far jankier than the performance impact ever would.*/
class FlagField extends StatefulWidget {
  final Ask ask;
  const FlagField({
    Key? key,
    required this.ask,
  }) : super(key: key);

  @override
  State<FlagField> createState() => _FlagFieldState();
}

class _FlagFieldState extends State<FlagField> {
  late final BaseEntity entity =
      BridgeHandler.findByCode(widget.ask.targetCode);
  bool value = false;
  late final EntityAttribute answers =
      entity.findAttribute(widget.ask.attributeCode);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: widget.ask.mandatory
          ? const EdgeInsets.symmetric(horizontal: 16).copyWith(left: 12)
          : null,
      shape: widget.ask.mandatory
          ? const Border(left: BorderSide(color: Colors.red, width: 4))
          : null,
      trailing: Switch(
          value: entity.findAttribute(widget.ask.attributeCode).valueBoolean,
          onChanged: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() {
              entity.findAttribute(widget.ask.attributeCode).valueBoolean = _;
            });
            widget.ask.answer(_.toString().toUpperCase());
          }),
      title: Text(widget.ask.name),
    );
  }
}
