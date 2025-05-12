import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  @JsonKey(name: 'token')
  final String? token; // Artık "plainText" değil, "token" ve null olabilir

  final DateTime? expiry; // Null olabilir

  Token({
    required this.token, // Token null geliyorsa burası sorun yaratabilir.
    this.expiry,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}