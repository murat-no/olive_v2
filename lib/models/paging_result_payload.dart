import 'package:json_annotation/json_annotation.dart';

part 'paging_result_payload.g.dart';

// Backend'den gelen yanıtın "pagingResult" anahtarının değerini temsil eder.
// İçinde error, message, sayfalama bilgileri ve asıl veri listesi (List<T>) bulunur.
@JsonSerializable(genericArgumentFactories: true) // Jenerik tipler için build_runner ayarı
class PagingResultPayload<T> {
  final bool error; // Backend'in error flag'i
  final String message; // Backend'in mesajı

  // Backend'den Integer olarak gelen sayfalama bilgileri
  // JSON'da her zaman geldiklerini varsayıyoruz ama nullable yapalım daha güvenli olur
  final int? rowCount;
  final int? currentPage;
  final int? pageSize;

  // Asıl veri listesi. Backend her zaman bir liste [] döndürür, boş olabilir.
  // Bu yüzden List<T> ama listenin kendisi null da gelebilir mi? JSON'da [] görünüyor.
  // Daha güvenlisi listeyi de nullable yapmak: List<T>?
  // Ancak backend [] gönderiyorsa ve null göndermiyorsa List<T> yeterlidir.
  // Çoğu backend boş liste döndürür. List<T> yapalım, ihtiyaca göre List<T>? yaparız.
  // data alanı, içindeki objeleri (T tipinde) fromJsonT fonksiyonu ile dönüştürecek.
  final List<T>? data; // ✨ Liste de null olabilir mi? Güvenli olması için nullable yapıyoruz. ✨


  PagingResultPayload({
    required this.error,
    required this.message,
    this.rowCount,
    this.currentPage,
    this.pageSize,
    this.data, // Nullable
  });

  // JSON'dan PagingResultPayload<T> objesi oluşturacak factory metot (build_runner üretir)
  // T tipindeki liste elemanlarını dönüştürmek için fromJsonT adlı bir fonksiyona ihtiyaç duyar.
  factory PagingResultPayload.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$PagingResultPayloadFromJson(json, fromJsonT);

  // PagingResultPayload<T> objesini JSON'a dönüştürececek metot (build_runner üretir)
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PagingResultPayloadToJson(this, toJsonT);
}