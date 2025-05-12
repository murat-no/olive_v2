// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      error: json['error'] as bool,
      message: json['message'] as String,
      bearertoken: json['bearertoken'] == null
          ? null
          : Token.fromJson(json['bearertoken'] as Map<String, dynamic>),
      userName: json['userName'] as String?,
      userRole: json['userRole'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
      'bearertoken': instance.bearertoken,
      'userName': instance.userName,
      'userRole': instance.userRole,
    };
