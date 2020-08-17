import 'package:intl/intl.dart';

import 'package:json_annotation/json_annotation.dart';
part 'Answer.g.dart';

@JsonSerializable(explicitToJson: true)
class Answer {
  Answer(this.sourceCode, this.targetCode, this.attributeCode, this.value);

  String created =
      DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now().toUtc()) +
          ".${DateTime.now().toUtc().millisecond}";
  String value;
  String attributeCode;
  int askId = -1;
  String targetCode;
  String sourceCode;
  bool expired = false;
  bool refused = false;
  double weight = 1.0;
  bool inferred = false;
  bool changeEvent = false;

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}
