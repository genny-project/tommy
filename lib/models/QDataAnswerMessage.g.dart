// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QDataAnswerMessage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QDataAnswerMessage _$QDataAnswerMessageFromJson(Map<String, dynamic> json) {
  return QDataAnswerMessage(
    (json['items'] as List)
        ?.map((e) =>
            e == null ? null : Answer.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )
    ..data_type = json['data_type'] as String
    ..msg_type = json['msg_type'] as String
    ..delete = json['delete'] as bool
    ..replace = json['replace'] as bool
    ..option = json['option'] as String
    ..token = json['token'] as String;
}

Map<String, dynamic> _$QDataAnswerMessageToJson(QDataAnswerMessage instance) =>
    <String, dynamic>{
      'data_type': instance.data_type,
      'msg_type': instance.msg_type,
      'items': instance.items?.map((e) => e?.toJson())?.toList(),
      'delete': instance.delete,
      'replace': instance.replace,
      'option': instance.option,
      'token': instance.token,
    };
