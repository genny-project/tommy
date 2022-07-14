import 'package:flutter/material.dart';
import 'package:geoff/geoff.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';

class RichtextEditor extends StatefulWidget {
  const RichtextEditor({Key? key, required this.ask}) : super(key: key);
  final Ask ask;

  @override
  State<RichtextEditor> createState() => _RichtextEditorState();
}

enum Mod { bold, italic, underline, unordered, ordered }

Map<Mod, String> tags = {
  Mod.bold: "b",
  Mod.italic: "i",
  Mod.underline: "u",
  Mod.unordered: "ul",
  Mod.ordered: "ol"
};

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
          text: BridgeHandler.findByCode(widget.ask.targetCode)
              .findAttribute(widget.ask.attributeCode)
              .valueString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: Colors.black, width: 2)),
        title: Column(
          children: [
            Text(
              widget.ask.name,
            ),
            IntrinsicHeight(
              child: Wrap(
                children: [
                  IconButton(
                      onPressed: () {
                        styleText(Mod.bold);
                      },
                      icon: const Icon(Icons.format_bold)),
                  const VerticalDivider(
                    thickness: 1,
                  ),
                  IconButton(
                      onPressed: () {
                        styleText(Mod.italic);
                      },
                      icon: const Icon(Icons.format_italic)),
                  const VerticalDivider(
                    thickness: 1,
                  ),
                  IconButton(
                      onPressed: () {
                        styleText(Mod.underline);
                      },
                      icon: const Icon(Icons.format_underline)),
                  const VerticalDivider(
                    thickness: 1,
                  ),
                  IconButton(
                      onPressed: () {
                        styleText(Mod.unordered);
                      },
                      icon: const Icon(Icons.format_list_bulleted)),
                  const VerticalDivider(
                    thickness: 1,
                  ),
                  IconButton(
                      onPressed: () {
                        styleText(Mod.ordered);
                      },
                      icon: const Icon(Icons.format_list_numbered)),
                  const VerticalDivider(
                    thickness: 1,
                  ),
                ],
              ),
            ),
            Focus(
              onFocusChange: ((value) {
                answerValue = _controller.text;
                if (!value) {
                  widget.ask.answer(answerValue);
                }
              }),
              child: TextField(
                controller: _controller,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  void Function() f = () {};
                  f = () {
                    if (FocusManager.instance.primaryFocus?.hasFocus == false) {
                      widget.ask.answer(answerValue);
                      // focus.unfocus();
                      FocusManager.instance.primaryFocus?.unfocus();
                      FocusManager.instance.primaryFocus?.removeListener(f);
                    }
                  };
                  FocusManager.instance.primaryFocus?.requestFocus();
                  FocusManager.instance.primaryFocus?.addListener(f);
                },
                onChanged: (value) {
                  BridgeHandler.findByCode(widget.ask.targetCode)
                      .findAttribute(widget.ask.attributeCode)
                      .valueString = value;
                  setState(() {
                    answerValue = value;
                  });
                },
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            RichText(
                text: RichTextBlock.generate(_controller.text)
                    .toTextSpans(const TextStyle(color: Colors.black)))
          ],
        ));
  }

  int getLineNumber() {
    _controller.text.split('\n');
    List<int> lineLengths = [];
    _controller.text.split('\n').forEach((line) {
      lineLengths.add(line.length);
    });
    int lineNumber = 0;
    int tempLength = _controller.selection.baseOffset - 1;
    for (int i = 0; i < lineLengths.length; i++) {
      if (i > 0) {
        if (tempLength -
                lineLengths
                    .getRange(0, i)
                    .reduce((value, element) => value + element) -
                i >
            0) {
          lineNumber = i;
        }
      } else {
        lineNumber = 0;
      }
    }
    return lineNumber;
  }

  void styleText(Mod textMod) {
    int lineNumber = getLineNumber();
    int tempLength = _controller.selection.baseOffset;
    List lines = _controller.text.split('\n');
    if (textMod == Mod.ordered || textMod == Mod.unordered) {
      setState(() {
        lines[lineNumber] +=
            "\n<${tags[textMod]}>\n\t<li>Item</li>\n</${tags[textMod]}>";
        _controller.text = lines.join("\n");
        _controller.selection =
            TextSelection.fromPosition(TextPosition(offset: tempLength + 4));
      });
    } else if (_controller.selection.start != _controller.selection.end) {
      List<String> text = _controller.text.split('')
        ..insert(_controller.selection.start, "<${tags[textMod]}>")
        ..insert(_controller.selection.end, "</${tags[textMod]}>");
      _controller.text = text.join('');
      _controller.selection =
          TextSelection.fromPosition(TextPosition(offset: tempLength + 3));
    } else {
      lines[lineNumber] =
          "<${tags[textMod]}>${lines[lineNumber]}</${tags[textMod]}>";

      setState(() {
        _controller.text = lines.join("\n");
      });
      _controller.selection =
          TextSelection.fromPosition(TextPosition(offset: tempLength + 3));
    }
  }
}

List<String> splitWithDelim(String input, RegExp expression, [int start = 0]) {
  var result = <String>[];
  for (var match in expression.allMatches(input, start)) {
    result.add(input.substring(start, match.start));
    result.add(match[0]!);
    start = match.end;
  }
  result.add(input.substring(start));
  return result;
}
