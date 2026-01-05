
import 'package:json_annotation/json_annotation.dart';
import 'package:socail/modules/posts/models/photo.dart';
import 'package:socail/modules/posts/models/picture.dart';

import '../../../models/user.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  @JsonKey(name: 'id', includeIfNull: false)
  final String? id;

  @JsonKey(name: 'status', includeIfNull: false)
  final int? status;

  @JsonKey(name: 'title', includeIfNull: false)
  final String? title;

  @JsonKey(name: 'description', includeIfNull: false)
  final String? description;
  @JsonKey(name: 'created_at', includeIfNull: false)
  final String? created_at;

  @JsonKey(name: 'images', includeIfNull: false)
  final List<Picture>? images;

  @JsonKey(name: 'photos', includeIfNull: false)
  final List<Photo>? photos;
  @JsonKey(name: 'user', includeIfNull: false)
  final User? user;
  @JsonKey(name: 'comment_counts', includeIfNull: false)
   int? commentCounts;

  @JsonKey(name: 'like_counts', includeIfNull: false)
  int? likeCounts;

  @JsonKey(name: 'liked', includeIfNull: false)
  bool? liked;
  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Post({
    this.id,
    this.status,
    this.title,
    this.description,
    this.created_at,
    this.images,
    this.photos,
    this.user,
    this.liked,
    this.likeCounts,
    this.commentCounts
  });
  String? get urlUserAvatar => user?.imgUrl;

  String get displayName => user?.displayName ?? '';

    List<Photo> getDisplayPhotos() {
    
    if (photos != null && photos!.isNotEmpty) {
      return photos!;
    }
    if (images != null && images!.isNotEmpty) {
      final photosList = images!.map((picture) {
        return Photo(
          image: picture,
        );
      }).toList();
      return photosList;
    }
    return [];
  }

    bool hasImages() {
    return (photos?.isNotEmpty ?? false) || (images?.isNotEmpty ?? false);
  }

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

