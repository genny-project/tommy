import 'package:flutter/material.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/utils/bridge_handler.dart';

class RichtextEditor extends StatefulWidget {
  const RichtextEditor({Key? key, required this.ask}) : super(key: key);
  final Ask ask;

  @override
  State<RichtextEditor> createState() => _RichtextEditorState();
}

class _RichtextEditorState extends State<RichtextEditor> {
  // ignore: unused_field
  final Log _log = Log("RichtextEditor");
  late TextEditingController _controller;
  String answerValue = "";
  @override
  void initState() {
    super.initState();
    setState(() {
      _controller = TextEditingController(
          text: BridgeHandler.findAttribute(
                  BridgeHandler.findByCode(widget.ask.targetCode),
                  widget.ask.attributeCode)
              .valueString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: Colors.black, width: 2)),
        title: Column(
          children: [
            Text(
              "${widget.ask.name} ${widget.ask.question.attribute.dataType.component}",
            ),
            Focus(
              onFocusChange: ((value) {
                answerValue = _controller.text;
                if (!value) {
                  BridgeHandler.answer(widget.ask, answerValue);
                }
              }),
              child: TextField(
                controller: _controller,
                onTap: () {
                  // FocusManager.instance.primaryFocus?.unfocus();
                  // void Function() f = () {};
                  // f = () {
                  //   print("Has focus ${FocusManager.instance.primaryFocus?.hasFocus}");
                  //   if (FocusManager.instance.primaryFocus?.hasFocus == false) {
                  //     BridgeHandler.answer(ask, value);
                  //     // focus.unfocus();
                  //     FocusManager.instance.primaryFocus?.unfocus();
                  //     FocusManager.instance.primaryFocus?.removeListener(f);
                  //   }
                  // };
                  // FocusManager.instance.primaryFocus?.requestFocus();
                  // FocusManager.instance.primaryFocus?.addListener(f);
                },

                // focusNode: FocusManager.instance.primaryFocus,
                onChanged: (value) {
                  BridgeHandler.findAttribute(
                  BridgeHandler.findByCode(widget.ask.targetCode),
                  widget.ask.attributeCode)
              .valueString = value;
                  answerValue = value;
                  // BridgeHandler.answer(ask, value);
                },
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ));
  }
}
