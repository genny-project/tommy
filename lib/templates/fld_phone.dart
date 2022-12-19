import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/phone_utils.dart';
import 'package:tommy/utils/template_handler.dart';

class PhoneField extends StatefulWidget {
  final Ask ask;
  const PhoneField({
    Key? key,
    required this.ask,
  }) : super(key: key);

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  late final BaseEntity entity =
      BridgeHandler.findByCode(widget.ask.targetCode);
  String value = "";
  Map<String, dynamic>? code;
  Timer? timer;
  @override
  Widget build(BuildContext context) {
    TemplateHandler.contexts[widget.ask.question.code] = context;
    // return Text("");
    return ListTile(
      // shape: widget.ask.mandatory
      //     ? const Border(left: BorderSide(color: Colors.red, width: 4))
      //     : null,
      title: Focus(
        onFocusChange: ((focus) {
          if (!focus) {
            entity.findAttribute(widget.ask.attributeCode).valueString =
                code?['code'] + value;
            widget.ask.answer(code?['code'] + value);
          }
        }),
        child: TextFormField(
            
            keyboardType: maskType(entity
                .findAttribute(widget.ask.attributeCode)
                .attribute
                .dataType),
            // controller: TextEditingController(text: entity.findAttribute(widget.ask.attributeCode).valueString),
            onChanged: (newValue) {
              setState(() {
                value = newValue;
              });
              timer?.cancel();
              timer = Timer(Duration(milliseconds: 800), () {
                entity.findAttribute(widget.ask.attributeCode).valueString =
                    code?['code'] + value;
                widget.ask.answer(code?['code'] + value);
              });
            },
            initialValue: entity
                .findAttribute(widget.ask.attributeCode)
                .getValue()
                .toString(),
            // entity.findAttribute(widget.ask.attributeCode).valueString,
            autovalidateMode: AutovalidateMode.always,
            validator: BridgeHandler.createValidator(widget.ask,
                value: code == null ? null : code!['code'] + value),
            onFieldSubmitted: (newValue) {
              value = newValue;
              entity.findAttribute(widget.ask.attributeCode).valueString =
                  newValue;
              widget.ask.answer(value);
            },
            decoration: InputDecoration(
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                // prefixIcon: Text(""),
                prefixIcon: PopupMenuButton(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(code == null
                              ? "Code"
                              : code?['icon'] + " " + code?['code']),
                          Icon(Icons.expand_more)
                        ],
                      ),
                    ),
                    itemBuilder: (context) {
                      return List.generate(
                          PhoneUtils.countryList.length,
                          (index) => PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  code = PhoneUtils.countryList[index];
                                });
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(PhoneUtils.countryList[index]
                                          ['icon'])),
                                  Expanded(
                                      child: Text(PhoneUtils.countryList[index]
                                          ['code'])),
                                  Expanded(
                                      flex: 4,
                                      child: Text(PhoneUtils.countryList[index]
                                          ['name']))
                                ],
                              )));
                    }),
                filled: true,
                fillColor: Colors.grey[250],
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2)),
                focusColor: Theme.of(context).colorScheme.secondary,
                // Text('*', style: TextStyle(color: Colors.red, fontSize: 24),),
                label: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(widget.ask.name),
                  widget.ask.mandatory
                      ? Text(
                          "*",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                          ),
                        )
                      : SizedBox()
                ]),
                border: InputBorder.none,
                errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2)),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2)),
                labelStyle: TextStyle(decorationColor: Colors.red))),
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
