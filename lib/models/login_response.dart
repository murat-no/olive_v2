import 'package:json_annotation/json_annotation.dart';
import 'token.dart'; // Güncellenmiş Token modelini import et

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final bool error;
  final String message;

  // Backend'den gelen anahtar "bearertoken" (küçük harf)
  @JsonKey(name: 'bearertoken') // <-- BURASI DÜZELTİLDİ! "bearertoken" (küçük harf)
  final Token? bearertoken; // Token objesi (yukarıda düzelttiğimiz)

  @JsonKey(name: 'userName') // Backend'deki alan adı "userName" - Bu zaten doğruydu
  final String? userName;

  @JsonKey(name: 'userRole') // Backend'deki alan adı "userRole" - Bu zaten doğruydu
  final String? userRole;

  LoginResponse({
    required this.error,
    required this.message,
    this.bearertoken,
    this.userName,
    this.userRole,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}