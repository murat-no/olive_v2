import 'package:json_annotation/json_annotation.dart';
import 'paging_result_payload.dart'; // PagingResultPayload modelini import et

part 'backend_response.g.dart';

// Backend'den gelen en üst seviyedeki tam JSON yanıtını temsil eder.
// Tüm non-login API'leri için { "pagingResult": { ... } } yapısını karşılar.
@JsonSerializable(genericArgumentFactories: true) // Jenerik tipler için build_runner ayarı
class BackendResponse<T> {
  // Backend'den gelen "pagingResult" anahtarının değeri PagingResultPayload<T> olacak
  @JsonKey(name: 'pagingResult') // Backend'deki anahtar adı
  final PagingResultPayload<T>? pagingResult; // ✨ pagingResult null olabilir mi? Güvenli olması için nullable yapıyoruz. ✨


  BackendResponse({
    this.pagingResult, // Nullable
  });

  // JSON'dan BackendResponse<T> objesi oluşturacak factory metot (build_runner üretir)
  // İçindeki PagingResultPayload<T> objesini dönüştürmek için fromJsonT adlı bir fonksiyona ihtiyaç duyar.
  // fromJsonT, PagingResultPayload<T> objesinin içindeki List<T> elemanlarını dönüştürecek fonksiyonu alacak.
  factory BackendResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$BackendResponseFromJson(json, fromJsonT);

  // BackendResponse<T> objesini JSON'a dönüştürecek metot (build_runner üretir)
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BackendResponseToJson(this, toJsonT);
}