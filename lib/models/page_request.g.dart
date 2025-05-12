// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageRequest _$PageRequestFromJson(Map<String, dynamic> json) => PageRequest(
      currentPage: (json['currentPage'] as num).toInt(),
      rowsPerPage: (json['rowsPerPage'] as num).toInt(),
      lang: json['lang'] as String,
      queryCriteria: (json['QueryCriteria'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$PageRequestToJson(PageRequest instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'rowsPerPage': instance.rowsPerPage,
      'lang': instance.lang,
      'QueryCriteria': instance.queryCriteria,
    };
