
import 'package:json_annotation/json_annotation.dart';
import 'package:socail/modules/posts/models/picture.dart';

import '../../../models/user.dart';

part 'photo.g.dart';

@JsonSerializable()
class Photo {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'created_at', includeIfNull: false)
  final DateTime? createdAt;

  @JsonKey(name: 'title', includeIfNull: false)
  final String? title;

  @JsonKey(name: 'description', includeIfNull: false)
  final String? description;

  @JsonKey(name: 'image', includeIfNull: false)
  final Picture? image;

  @JsonKey(name: 'comment_counts', includeIfNull: false)
  final int? commentCounts;

  @JsonKey(name: 'like_counts', includeIfNull: false)
  int? likeCounts;

  @JsonKey(name: 'collection_counts', includeIfNull: false)
  final int? collectionCounts;

  @JsonKey(name: 'view_counts', includeIfNull: false)
  final int? viewCounts;

  @JsonKey(name: 'is_private', includeIfNull: false)
  final bool? isPrivate;

  @JsonKey(name: 'is_sensitive', includeIfNull: false)
  final bool? isSensitive;

  @JsonKey(name: 'storage_length', includeIfNull: false)
  final int? storageLength;

  @JsonKey(name: 'user', includeIfNull: false)
  final User? user;

  @JsonKey(name: 'liked', includeIfNull: false)
  bool? liked;

  

  Photo({
    this.id,
    this.createdAt,
    this.title,
    this.description,
    this.image,
    this.commentCounts,
    this.likeCounts,
    this.collectionCounts,
    this.viewCounts,
    this.isPrivate,
    this.isSensitive,
    this.storageLength,
    this.user,
    this.liked,
  });
  String get url => image?.url ?? '';
  String get imgurl => image?.imgUrl ?? '';

  



  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoToJson(this);
}

