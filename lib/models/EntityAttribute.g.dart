// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'EntityAttribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityAttribute _$EntityAttributeFromJson(Map<String, dynamic> json) {
  return EntityAttribute(
    json['baseentityCode'] as String,
    json['attributeCode'] as String,
    json['attributeName'] as String,
    json['valueString'] as String,
  )
    ..uuid = json['uuid'] as String
    ..readonly = json['readonly'] as bool
    ..index = json['index'] as int
    ..id = json['id'] as int
    ..created = json['created'] as String
    ..valueDouble = (json['valueDouble'] as num)?.toDouble()
    ..valueBoolean = json['valueBoolean'] as bool
    ..valueInteger = json['valueInteger'] as int
    ..valueDate = json['valueDate'] == null
        ? null
        : DateTime.parse(json['valueDate'] as String)
    ..valueDateTime = json['valueDateTime'] == null
        ? null
        : DateTime.parse(json['valueDateTime'] as String)
    ..weight = (json['weight'] as num)?.toDouble()
    ..inferred = json['inferred'] as bool
    ..privacyFlag = json['privacyFlag'] as bool;
}

Map<String, dynamic> _$EntityAttributeToJson(EntityAttribute instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'baseentityCode': instance.baseentityCode,
      'attributeCode': instance.attributeCode,
      'attributeName': instance.attributeName,
      'readonly': instance.readonly,
      'index': instance.index,
      'id': instance.id,
      'created': instance.created,
      'valueString': instance.valueString,
      'valueDouble': instance.valueDouble,
      'valueBoolean': instance.valueBoolean,
      'valueInteger': instance.valueInteger,
      'valueDate': instance.valueDate?.toIso8601String(),
      'valueDateTime': instance.valueDateTime?.toIso8601String(),
      'weight': instance.weight,
      'inferred': instance.inferred,
      'privacyFlag': instance.privacyFlag,
    };
