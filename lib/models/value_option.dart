import 'package:json_annotation/json_annotation.dart';

part 'value_option.g.dart';

// Backend'den gelen değer listesi öğesini temsil eder (Definitions struct'ına karşılık gelir)
@JsonSerializable()
class ValueOption {
  @JsonKey(name: 'type') // Backend'deki JSON alanı "type"
  final String? defType;
  @JsonKey(name: 'lang') // Backend'deki JSON alanı "lang"
  final String? lang;
  @JsonKey(name: 'id') // Backend'deki JSON alanı "id" (Bu değer _key alanlarına karşılık gelecek)
  final String? id;
  @JsonKey(name: 'value') // Backend'deki JSON alanı "value" (Kullanıcıya gösterilecek metin)
  final String? value;
  @JsonKey(name: 'description') // Backend'deki JSON alanı "description"
  final String? description;
  @JsonKey(name: 'parent_def') // Backend'deki JSON alanı "parent_def" (Bağımlı listeler için)
  final String? parentKey;
  @JsonKey(name: 'info_image_link') // Backend'deki JSON alanı "info_image_link"
  final String? infoImageLink;


  ValueOption({
    this.defType,
    this.lang,
    this.id, // _key olarak kullanılacak
    this.value, // Display olarak kullanılacak
    this.description,
    this.parentKey, // Bağımlılık için kullanılacak
    this.infoImageLink,
  });

  factory ValueOption.fromJson(Map<String, dynamic> json) => _$ValueOptionFromJson(json);
  Map<String, dynamic> toJson() => _$ValueOptionToJson(this);
}