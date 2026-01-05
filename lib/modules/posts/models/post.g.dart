// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: json['id'] as String?,
  status: (json['status'] as num?)?.toInt(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  created_at: json['created_at'] as String?,
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => Picture.fromJson(e as Map<String, dynamic>))
      .toList(),
  photos: (json['photos'] as List<dynamic>?)
      ?.map((e) => Photo.fromJson(e as Map<String, dynamic>))
      .toList(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  liked: json['liked'] as bool?,
  likeCounts: (json['like_counts'] as num?)?.toInt(),
  commentCounts: (json['comment_counts'] as num?)?.toInt(),
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': ?instance.id,
  'status': ?instance.status,
  'title': ?instance.title,
  'description': ?instance.description,
  'created_at': ?instance.created_at,
  'images': ?instance.images,
  'photos': ?instance.photos,
  'user': ?instance.user,
  'comment_counts': ?instance.commentCounts,
  'like_counts': ?instance.likeCounts,
  'liked': ?instance.liked,
};
