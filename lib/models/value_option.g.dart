// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'value_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValueOption _$ValueOptionFromJson(Map<String, dynamic> json) => ValueOption(
      defType: json['type'] as String?,
      lang: json['lang'] as String?,
      id: json['id'] as String?,
      value: json['value'] as String?,
      description: json['description'] as String?,
      parentKey: json['parent_def'] as String?,
      infoImageLink: json['info_image_link'] as String?,
    );

Map<String, dynamic> _$ValueOptionToJson(ValueOption instance) =>
    <String, dynamic>{
      'type': instance.defType,
      'lang': instance.lang,
      'id': instance.id,
      'value': instance.value,
      'description': instance.description,
      'parent_def': instance.parentKey,
      'info_image_link': instance.infoImageLink,
    };
