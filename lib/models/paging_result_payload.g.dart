// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paging_result_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PagingResultPayload<T> _$PagingResultPayloadFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PagingResultPayload<T>(
      error: json['error'] as bool,
      message: json['message'] as String,
      rowCount: (json['rowCount'] as num?)?.toInt(),
      currentPage: (json['currentPage'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)?.map(fromJsonT).toList(),
    );

Map<String, dynamic> _$PagingResultPayloadToJson<T>(
  PagingResultPayload<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
      'rowCount': instance.rowCount,
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
      'data': instance.data?.map(toJsonT).toList(),
    };
