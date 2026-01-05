// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  username: json['username'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  avatar: json['avatar'] == null
      ? null
      : Picture.fromJson(json['avatar'] as Map<String, dynamic>),
  bio: json['bio'] as String?,
  isVerified: json['is_verified'] as bool? ?? false,
  isAdmin: json['is_admin'] as bool? ?? false,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'avatar': instance.avatar,
  'bio': instance.bio,
  'is_verified': instance.isVerified,
  'is_admin': instance.isAdmin,
};
