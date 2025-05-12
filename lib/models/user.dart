import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  @JsonKey(name: 'user_name') // Backend'deki alan adı "user_name"
  final String userName;
  @JsonKey(name: 'full_name') // Backend'deki alan adı "full_name"
  final String fullName;
  final String email;
  @JsonKey(name: 'role') // Backend'deki alan adı "role"
  final String userRole; // Dart'ta "role" yerine "userRole" kullanıyoruz isim çakışmasını önlemek için
  @JsonKey(name: 'enabled_flag') // Backend'deki alan adı "enabled_flag"
  final String enabledFlag;

  User({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.email,
    required this.userRole,
    required this.enabledFlag,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}