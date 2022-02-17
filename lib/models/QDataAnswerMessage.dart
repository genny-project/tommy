

import 'package:json_annotation/json_annotation.dart';

import 'Answer.dart';
part 'QDataAnswerMessage.g.dart';

@JsonSerializable(explicitToJson: true)
class QDataAnswerMessage {

  String data_type = "Answer";
  String msg_type = "DATA_MSG";

  List<Answer> items = [];

  bool delete = false;
  bool replace = false;
  String option = "EXEC";
  String token = "DUMMY";


  QDataAnswerMessage(this.items);

  addAnswers(List<Answer> answers) {
    this.items.addAll(answers);
  }

  // QDataAnswerMessage.fromJson(Map<String, dynamic> json)
  //     : 
  //     delete = json['delete'],
  //     replace = json['replace'];


  // Map<String, dynamic> toJson() =>
  //   {
  //     'data_type': data_type,
  //     'msg_type': msg_type,
  //     'delete' : delete,
  //     'replace' : replace,
  //     'option' : option,
  //     'token' : token
  //   };

  factory QDataAnswerMessage.fromJson(Map<String, dynamic> json) => _$QDataAnswerMessageFromJson(json);
  Map<String, dynamic> toJson() => _$QDataAnswerMessageToJson(this);
}