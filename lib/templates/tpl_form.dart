import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/template_handler.dart';

import '../utils/bridge_handler.dart';

class GennyForm extends StatefulWidget {
  final BaseEntity entity;
  const GennyForm({Key? key, required this.entity}) : super(key: key);

  @override
  State<GennyForm> createState() => _GennyFormState();
}

class _GennyFormState extends State<GennyForm> {
  List<Ask> allQuestions = [];
  FocusNode fNode = FocusNode();
  final _selectNotifier = ValueNotifier<String>("");
  String? focusField;
  @override
  void dispose() {
    _selectNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Ask? qGroup = BridgeHandler
        .askData[widget.entity.findAttribute("PRI_QUESTION_CODE").valueString]
      ?..childAsks.sort(((a, b) {
        return a.weight.compareTo(b.weight);
      }));

    if (qGroup != null) {
      for (Ask ask in qGroup.childAsks) {
        ask.attributeCode != "QQQ_QUESTION_GROUP"
            ? allQuestions.add(ask)
            : allQuestions.addAll(ask.childAsks);
      }
    }
    if (qGroup != null) {
      //this listener allows me to update the selected field without rebuilding every widget in the form
      return ValueListenableBuilder(
        valueListenable: _selectNotifier,
        builder: ((context, value, child) {
          return Column(children: [
            ListTile(
                title: Text(
              qGroup.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.start,
            )),
            ...List.generate(
              qGroup.childAsks.length,
              (index) {
                if (qGroup.childAsks[index].attributeCode ==
                    "QQQ_QUESTION_GROUP") {
                  Ask ask = qGroup.childAsks[index];
                  return Column(
                      children: List.generate(ask.childAsks.length, (index) {
                    return field(ask.childAsks[index]);
                  }));
                }
                return field(qGroup.childAsks[index]);
              },
            ),
            UnansweredWidget(qGroup, (Ask ask) {
              // setState(() {
              _selectNotifier.value = ask.question.code;
              focusField = ask.question.code;
              // });
            }),
          ]);
        }),
      );
    } else {
      return const LinearProgressIndicator();
    }
  }

  Widget field(Ask ask) {
    return Container(
        decoration: focusField == ask.question.code
            ? const BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: Colors.red, width: 4,)))
            : null,
        child: TemplateHandler.getField(ask, context));
  }
}

class UnansweredWidget extends StatefulWidget {
  final Ask qGroup;
  final void Function(Ask ask) askSelect;
  const UnansweredWidget(
    this.qGroup,
    this.askSelect, {
    Key? key,
  }) : super(key: key);

  @override
  State<UnansweredWidget> createState() => _UnansweredWidgetState();
}

class _UnansweredWidgetState extends State<UnansweredWidget> {
  late void Function() f = () {
    setState(() {
      unansweredQ = unanswered();
    });
  };
  @override
  void initState() {
    BridgeHandler.message.addListener(f);
    super.initState();
  }

  @override
  void dispose() {
    BridgeHandler.message.removeListener(f);
    super.dispose();
  }

  List<Ask> getAll() {
    List<Ask> asks = [];
    for (Ask ask in widget.qGroup.childAsks) {
      ask.attributeCode != "QQQ_QUESTION_GROUP"
          ? asks.add(ask)
          : asks.addAll(ask.childAsks);
    }
    return asks;
  }

  List<Ask> unanswered() {
    return getAll()
        .toList()
        .where((ask) {
          var value = BridgeHandler.beData[ask.targetCode]
              ?.findAttribute(ask.attributeCode)
              .getValue();
          return (ask.mandatory == true && value == null || value == "");
        })
        .toSet()
        .toList();
  }

  late List<Ask> unansweredQ = unanswered();
  // List<Ask> unansweredQ = unanswered();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        unanswered().isNotEmpty
            ? const Text("Please fill the following required fields")
            : const SizedBox(),
        Wrap(
            alignment: WrapAlignment.center,
            spacing: 10.0,
            children: List.generate(
                unanswered().length,
                (index) => ActionChip(
                    visualDensity: VisualDensity(vertical: VisualDensity.minimumDensity),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(15 / 2))),
                    onPressed: () {
                      Scrollable.ensureVisible(
                          TemplateHandler
                              .contexts[unanswered()[index].question.code]!,
                          duration: const Duration(seconds: 1),
                          alignment: 0.5);

                      widget.askSelect(unanswered()[index]);
                    },
                    backgroundColor:
                        Theme.of(context).colorScheme.error.withAlpha(50),
                    label: Text(
                      
                      unanswered()[index].name,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withAlpha(150)),
                    )))),
      ],
    );
  }
}
