// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      userName: json['user_name'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      userRole: json['role'] as String,
      enabledFlag: json['enabled_flag'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'user_name': instance.userName,
      'full_name': instance.fullName,
      'email': instance.email,
      'role': instance.userRole,
      'enabled_flag': instance.enabledFlag,
    };
