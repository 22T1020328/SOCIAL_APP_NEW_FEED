// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
  id: json['id'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  title: json['title'] as String?,
  description: json['description'] as String?,
  image: json['image'] == null
      ? null
      : Picture.fromJson(json['image'] as Map<String, dynamic>),
  commentCounts: (json['comment_counts'] as num?)?.toInt(),
  likeCounts: (json['like_counts'] as num?)?.toInt(),
  collectionCounts: (json['collection_counts'] as num?)?.toInt(),
  viewCounts: (json['view_counts'] as num?)?.toInt(),
  isPrivate: json['is_private'] as bool?,
  isSensitive: json['is_sensitive'] as bool?,
  storageLength: (json['storage_length'] as num?)?.toInt(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  liked: json['liked'] as bool?,
);

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'title': ?instance.title,
  'description': ?instance.description,
  'image': ?instance.image,
  'comment_counts': ?instance.commentCounts,
  'like_counts': ?instance.likeCounts,
  'collection_counts': ?instance.collectionCounts,
  'view_counts': ?instance.viewCounts,
  'is_private': ?instance.isPrivate,
  'is_sensitive': ?instance.isSensitive,
  'storage_length': ?instance.storageLength,
  'user': ?instance.user,
  'liked': ?instance.liked,
};
