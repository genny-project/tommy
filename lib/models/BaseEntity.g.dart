// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BaseEntity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseEntity _$BaseEntityFromJson(Map<String, dynamic> json) {
  return BaseEntity(
    json['code'] as String,
    json['name'] as String,
  )
    ..uuid = json['uuid'] as String
    ..baseEntityAttributes = (json['baseEntityAttributes'] as List)
        ?.map((e) => e == null
            ? null
            : EntityAttribute.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..links = json['links'] as List
    ..questions = json['questions'] as List
    ..created = json['created'] as String
    ..realm = json['realm'] as String;
}

Map<String, dynamic> _$BaseEntityToJson(BaseEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'baseEntityAttributes':
          instance.baseEntityAttributes?.map((e) => e?.toJson())?.toList(),
      'links': instance.links,
      'questions': instance.questions,
      'code': instance.code,
      'created': instance.created,
      'name': instance.name,
      'realm': instance.realm,
    };
