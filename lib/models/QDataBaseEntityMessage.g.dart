// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QDataBaseEntityMessage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QDataBaseEntityMessage _$QDataBaseEntityMessageFromJson(
    Map<String, dynamic> json) {
  return QDataBaseEntityMessage(
    json['data_type'] as String,
    json['aliasCode'] as String,
    json['msg_type'] as String,
    json['option'] as String,
  )
    ..items = (json['items'] as List)
        ?.map((e) =>
            e == null ? null : BaseEntity.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..total = json['total'] as int
    ..returnCount = json['returnCount'] as int
    ..delete = json['delete'] as bool
    ..replace = json['replace'] as bool;
}

Map<String, dynamic> _$QDataBaseEntityMessageToJson(
        QDataBaseEntityMessage instance) =>
    <String, dynamic>{
      'items': instance.items?.map((e) => e?.toJson())?.toList(),
      'total': instance.total,
      'returnCount': instance.returnCount,
      'data_type': instance.data_type,
      'delete': instance.delete,
      'replace': instance.replace,
      'aliasCode': instance.aliasCode,
      'msg_type': instance.msg_type,
      'option': instance.option,
    };
