// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackendResponse<T> _$BackendResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    BackendResponse<T>(
      pagingResult: json['pagingResult'] == null
          ? null
          : PagingResultPayload<T>.fromJson(
              json['pagingResult'] as Map<String, dynamic>,
              (value) => fromJsonT(value)),
    );

Map<String, dynamic> _$BackendResponseToJson<T>(
  BackendResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'pagingResult': instance.pagingResult?.toJson(
        (value) => toJsonT(value),
      ),
    };
