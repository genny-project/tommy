import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

class GennyTextField extends StatefulWidget {
  final Ask ask;
  const GennyTextField({
    Key? key,
    required this.ask,
  }) : super(key: key);

  @override
  State<GennyTextField> createState() => _GennyTextFieldState();
}

class _GennyTextFieldState extends State<GennyTextField> {
  late final BaseEntity entity =
      BridgeHandler.findByCode(widget.ask.targetCode);
  String value = "";

  @override
  Widget build(BuildContext context) {
    BaseEntity entity = BridgeHandler.findByCode(widget.ask.targetCode);
          return ListTile(
            contentPadding: widget.ask.mandatory
                ? const EdgeInsets.symmetric(horizontal: 16).copyWith(left: 12)
                : null,
            
            shape: widget.ask.mandatory
                ? const Border(left: BorderSide(color: Colors.red, width: 4))
                : null,
            title: Focus(
              onFocusChange: ((focus) {
                if (!focus) {
                  widget.ask.answer(value);
                }
              }),
              child: TextFormField(
                  // controller: TextEditingController(text: entity.findAttribute(widget.ask.attributeCode).valueString),
                  onChanged: (newValue) {
                    value = newValue;
                  },
                  initialValue: entity.findAttribute(widget.ask.attributeCode).getValue().toString(),
                      // entity.findAttribute(widget.ask.attributeCode).valueString,
                  autovalidateMode: AutovalidateMode.always,
                  validator: BridgeHandler.createValidator(widget.ask),
                  onFieldSubmitted: (newValue) {
                    value = newValue;
                    widget.ask.answer(value);
                  },
                  decoration: InputDecoration(
                    labelText:
                        widget.ask.name,
                  )),
            ),
          );
  }
}
