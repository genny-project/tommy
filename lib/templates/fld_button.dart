import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/template_handler.dart';

class ButtonField extends StatefulWidget {
  final Ask ask;
  const ButtonField({
    Key? key,
    required this.ask,
  }) : super(key: key);

  @override
  State<ButtonField> createState() => _ButtonFieldState();
}

class _ButtonFieldState extends State<ButtonField> {
  late final BaseEntity entity =
      BridgeHandler.findByCode(widget.ask.targetCode);
  String value = "";
  @override
  Widget build(BuildContext context) {
    TemplateHandler.contexts[widget.ask.question.code] = context;
    return TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              widget.ask.disabled ? Colors.grey.withOpacity(0.2) : null),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                      color: widget.ask.disabled
                          ? Colors.grey
                          : Theme.of(context).colorScheme.secondary))),
        ),
        onPressed: widget.ask.disabled
            ? null
            : () {
                FocusManager.instance.primaryFocus?.unfocus();
                //TODO: find a better solution to simply waiting for focus to change arbitrarily
                Future.delayed(const Duration(seconds: 2), () {
                  widget.ask.evt();
                });
              },
        child: Text(widget.ask.name,
            style: TextStyle(
                color: widget.ask.disabled
                    ? Colors.grey
                    : Theme.of(context).colorScheme.secondary)));
  }
}
