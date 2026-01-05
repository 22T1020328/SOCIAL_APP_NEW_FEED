// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['id'] as String?,
  status: (json['status'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  content: json['content'] as String?,
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  liked: json['liked'] as bool?,
  likeCounts: (json['like_count'] as num?)?.toInt(),
  metaData: json['metadata'] == null
      ? null
      : CommentMetaData.fromJson(json['metadata'] as Map<String, dynamic>),
  parentCommentId: json['parent_comment_id'] as String?,
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': ?instance.id,
  'status': ?instance.status,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'content': ?instance.content,
  'user': ?instance.user,
  'liked': ?instance.liked,
  'like_count': ?instance.likeCounts,
  'metadata': instance.metaData,
  'parent_comment_id': ?instance.parentCommentId,
};
