// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'value_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValueOption _$ValueOptionFromJson(Map<String, dynamic> json) => ValueOption(
      defType: json['type'] as String?,
      lang: json['lang'] as String?,
      id: ValueOption._idFromJson(json['id']),
      value: json['value'] as String?,
      description: json['description'] as String?,
      parentKey: json['parent'] as String?,
      infoImageLink: json['info_image_link'] as String?,
    );

Map<String, dynamic> _$ValueOptionToJson(ValueOption instance) =>
    <String, dynamic>{
      'type': instance.defType,
      'lang': instance.lang,
      'id': ValueOption._idToJson(instance.id),
      'value': instance.value,
      'description': instance.description,
      'parent': instance.parentKey,
      'info_image_link': instance.infoImageLink,
    };
