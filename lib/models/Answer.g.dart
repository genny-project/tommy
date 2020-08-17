// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) {
  return Answer(
    json['sourceCode'] as String,
    json['targetCode'] as String,
    json['attributeCode'] as String,
    json['value'] as String,
  )
    ..created = json['created'] as String
    ..askId = json['askId'] as int
    ..expired = json['expired'] as bool
    ..refused = json['refused'] as bool
    ..weight = (json['weight'] as num)?.toDouble()
    ..inferred = json['inferred'] as bool
    ..changeEvent = json['changeEvent'] as bool;
}

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
      'created': instance.created,
      'value': instance.value,
      'attributeCode': instance.attributeCode,
      'askId': instance.askId,
      'targetCode': instance.targetCode,
      'sourceCode': instance.sourceCode,
      'expired': instance.expired,
      'refused': instance.refused,
      'weight': instance.weight,
      'inferred': instance.inferred,
      'changeEvent': instance.changeEvent,
    };
