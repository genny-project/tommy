// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QBulkMessage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QBulkMessage _$QBulkMessageFromJson(Map<String, dynamic> json) {
  return QBulkMessage(
    json['data_type'] as String,
    (json['messages'] as List)
        ?.map((e) => e == null
            ? null
            : QDataBaseEntityMessage.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$QBulkMessageToJson(QBulkMessage instance) =>
    <String, dynamic>{
      'data_type': instance.data_type,
      'messages': instance.messages?.map((e) => e?.toJson())?.toList(),
    };
