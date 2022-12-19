import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tommy/generated/ask.pb.dart';
import 'package:tommy/generated/baseentity.pb.dart';
import 'package:tommy/utils/bridge_extensions.dart';
import 'package:tommy/utils/bridge_handler.dart';
import 'package:tommy/utils/google_utils.dart';
import 'package:tommy/utils/template_handler.dart';
import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class AddressField extends StatefulWidget {
  final Ask ask;
  const AddressField({
    Key? key,
    required this.ask,
  }) : super(key: key);

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  late final BaseEntity entity =
      BridgeHandler.findByCode(widget.ask.targetCode);
  String value = "";
  PlacesResult? result;
  Timer? timer;
  Prediction? answerPrediction;
  String key = BridgeHandler.getProject().findAttribute("PRI_GOOGLE_API_KEY").valueString;

  @override
  Widget build(BuildContext context) {
    TemplateHandler.contexts[widget.ask.question.code] = context;
    return ListTile(
        onTap: () async {
          result = null;
          answerPrediction = await showDialog<Prediction>(
              context: context,
              builder: (BuildContext dialogContext) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return SimpleDialog(
                      title: TextFormField(
                          // controller: TextEditingController(text: entity.findAttribute(widget.ask.attributeCode).valueString),
                          onChanged: (newValue) {
                            if (timer?.isActive ?? false) timer?.cancel();
                            timer =
                                Timer(Duration(milliseconds: 800), () async {
                              GoogleUtils.getSuggestions(newValue, key)
                                  .then((value) => setState(() {
                                        result = value;
                                      }));
                            });
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
                            entity
                                .findAttribute(widget.ask.attributeCode)
                                .valueString = newValue;
                            widget.ask.answer(value);
                          },
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[250],
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      width: 2)),
                              focusColor:
                                  Theme.of(context).colorScheme.secondary,
                              // Text('*', style: TextStyle(color: Colors.red, fontSize: 24),),
                              label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 2)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 2)),
                              labelStyle:
                                  TextStyle(decorationColor: Colors.red))),
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: result?.predictions.length ?? 0,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  Navigator.of(context)
                                      .pop(result!.predictions[index]);
                                },
                                title: Text(
                                    result!.predictions[index].description),
                              );
                            },
                          ),
                        )
                      ],
                    );
                  },
                );
              });
          if (answerPrediction != null) {
            GoogleUtils.getPlaceData(answerPrediction!.placeId!, key)
                .then((value) {
              String answerString =
                  jsonEncode(getAnswer(jsonDecode(value.body)));
              entity.findAttribute(widget.ask.attributeCode).valueString =
                  answerString;
              widget.ask.answer(answerString);
            });
          }
        },
        title: Text(widget.ask.name),
        subtitle: entity.findAttribute(widget.ask.attributeCode).getValue().isEmpty ? 
            null : Text(jsonDecode(entity.findAttribute(widget.ask.attributeCode).getValue())[
              'full_address'
            ]));
  }


  Map<String, dynamic>? getAnswer(Map<String, dynamic> data) {
    //this function will be a bit of a doozy on account of how the google maps data is returned to me
    Map<String, dynamic> answerData = {};
    List<dynamic> addressComponents() => data['result']['address_components'];
    Map<String, dynamic> getComponent(String key) {
      return addressComponents().firstWhereOrNull(
              (element) => (element["types"] as List<dynamic>).contains(key)) ??
          {};
    }

    answerData["country"] = getComponent("country")["long_name"] ?? "";
    answerData["full_address"] = answerPrediction!.description;
    answerData["latitude"] =
        data['result']['geometry']['location']['lat'] ?? "";
    answerData["longitude"] =
        data['result']['geometry']['location']['lng'] ?? "";
    answerData["state"] =
        getComponent("administrative_area_level_1")["long_name"] ?? "";
    answerData["street_name"] = getComponent("route")["long_name"] ?? "";
    answerData["street_number"] =
        getComponent("street_number")["long_name"] ?? "";
    answerData["street_address"] =
        answerData["street_number"] + " " + answerData["street_name"] ?? "";
    answerData["suburb"] = getComponent("locality")["long_name"] ?? "";
    return answerData;
  }
}
