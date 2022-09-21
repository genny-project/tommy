import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

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
  late final BaseEntity entity = BridgeHandler.findByCode(widget.ask.targetCode);
  String value = "";
  @override
  Widget build(BuildContext context) {
    TemplateHandler.contexts[widget.ask.question.code] = context;
    return ListTile(
      contentPadding: widget.ask.mandatory
           ? const EdgeInsets.symmetric(horizontal: 16).copyWith(left: 12)
           : null,
      // shape: widget.ask.mandatory
      //     ? const Border(left: BorderSide(color: Colors.red, width: 4))
      //     : null,
      title: Focus(
        onFocusChange: ((focus) {
          if (!focus) {
            entity.findAttribute(widget.ask.attributeCode).valueString = value;
            widget.ask.answer(value);
          }
        }),
        child: TextFormField(
            
            keyboardType: maskType(entity
                .findAttribute(widget.ask.attributeCode)
                .attribute
                .dataType),
            // controller: TextEditingController(text: entity.findAttribute(widget.ask.attributeCode).valueString),
            onChanged: (newValue) {
              value = newValue;
            },
            initialValue: entity
                .findAttribute(widget.ask.attributeCode)
                .getValue()
                .toString(),
            // entity.findAttribute(widget.ask.attributeCode).valueString,
            autovalidateMode: AutovalidateMode.always,
            validator: BridgeHandler.createValidator(widget.ask),
            onFieldSubmitted: (newValue) {
              value = newValue;
              entity.findAttribute(widget.ask.attributeCode).valueString =
                  newValue;
              widget.ask.answer(value);
            },
            decoration: InputDecoration(
              icon: Icon(Icons.info, color: Colors.red,), 
              // Text('*', style: TextStyle(color: Colors.red, fontSize: 24),),
              labelText: widget.ask.name,
            )),
      ),
    );
  }
}

TextInputType maskType(DataType dataType) {
  switch (dataType.dttCode) {
    case "DTT_INTEGER":
      {
        return TextInputType.number;
      }
    case "DTT_BIGDECIMAL":
      {
        return TextInputType.number;
      }
    case "DTT_TEXT":
      {
        return TextInputType.text;
      }
  }
  return TextInputType.text;
}
