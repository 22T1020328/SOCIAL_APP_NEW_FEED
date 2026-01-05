// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      actorId: json['actorId'] as String,
      actorName: json['actorName'] as String,
      actorAvatar: json['actorAvatar'] as String?,
      type: json['type'] as String,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      content: json['content'] as String?,
      isRead: json['isRead'] as bool,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'actorId': instance.actorId,
      'actorName': instance.actorName,
      'actorAvatar': instance.actorAvatar,
      'type': instance.type,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'content': instance.content,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt,
    };
