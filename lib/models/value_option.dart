// lib/models/value_option.dart

import 'package:json_annotation/json_annotation.dart';

part 'value_option.g.dart';

@JsonSerializable()
class ValueOption {
  @JsonKey(name: 'type')
  final String? defType;
  @JsonKey(name: 'lang')
  final String? lang;
  
  // ✨ KRİTİK DÜZELTME: Backend'den gelen 'id' alanını String olarak eşle ve parse et ✨
  @JsonKey(
    name: 'id', // Backend'den gelen JSON anahtarı 'id'
    fromJson: _idFromJson, // Integer'dan String'e daha güvenli dönüştürmek için özel fonksiyon
    toJson: _idToJson,     // String'den Integer'a geri dönüştürmek için özel fonksiyon
  )
  final String? id;

  @JsonKey(name: 'value')
  final String? value;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'parent')
  final String? parentKey;
  @JsonKey(name: 'info_image_link')
  final String? infoImageLink;


  ValueOption({
    this.defType,
    this.lang,
    this.id,
    this.value,
    this.description,
    this.parentKey,
    this.infoImageLink,
  });

  String get displayText => description ?? value ?? '';

  String? get idLower => id?.toLowerCase();
  String? get valueLower => value?.toLowerCase();


  factory ValueOption.fromJson(Map<String, dynamic> json) => _$ValueOptionFromJson(json);
  Map<String, dynamic> toJson() => _$ValueOptionToJson(this);


  // ✨ YENİ DÖNÜŞTÜRÜCÜ FONKSİYONLAR: dynamic'ten String'e daha güvenli çevirme ✨
  static String? _idFromJson(dynamic idJson) {
    if (idJson == null) return null;
    // Eğer idJson bir String ise doğrudan kullan, değilse toString() ile çevir.
    if (idJson is String) {
      return idJson;
    } else {
      return idJson.toString();
    }
  }

  // String'den int'e veya String'e geri dönüştürücü (toJson için, backend ne bekliyorsa)
  static dynamic _idToJson(String? idString) {
    if (idString == null || idString.isEmpty) return null;
    // Eğer backend ID'leri int bekliyorsa ve parse edilebiliyorsa int.
    // Aksi takdirde String olarak gönder.
    try {
      return int.parse(idString);
    } catch (e) {
      return idString; // Parse edilemezse string olarak kalsın (UUID'ler için)
    }
  }
}