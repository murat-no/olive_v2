import 'package:json_annotation/json_annotation.dart';

part 'page_request.g.dart';

@JsonSerializable()
class PageRequest {
  final int currentPage;
  final int rowsPerPage;
  final String lang;
  @JsonKey(name: 'QueryCriteria') // Backend'deki anahtar adı
  final Map<String, String>? queryCriteria; // Null olabilir eğer kriter yoksa

  PageRequest({
    required this.currentPage,
    required this.rowsPerPage,
    required this.lang,
    this.queryCriteria, // Nullable
  });

  factory PageRequest.fromJson(Map<String, dynamic> json) => _$PageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PageRequestToJson(this);
}