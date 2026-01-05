import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String userId; 
  final String actorId; 
  final String actorName;
  final String? actorAvatar;
  final String type; 
  final String? postId;
  final String? commentId;
  final String? content; 
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.actorId,
    required this.actorName,
    this.actorAvatar,
    required this.type,
    this.postId,
    this.commentId,
    this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

    String get message {
    switch (type) {
      case 'like_post':
        return 'đã thích bài viết của bạn';
      case 'like_comment':
        return 'đã thích bình luận của bạn';
      case 'comment':
        return 'đã bình luận bài viết của bạn: $content';
      case 'follow':
        return 'đã bắt đầu theo dõi bạn';
      default:
        return 'đã tương tác với bạn';
    }
  }

    String get icon {
    switch (type) {
      case 'like_post':
      case 'like_comment':
        return '❤️';
      case 'comment':
        return '💬';
      case 'follow':
        return '👤';
      default:
        return '🔔';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? actorId,
    String? actorName,
    String? actorAvatar,
    String? type,
    String? postId,
    String? commentId,
    String? content,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorAvatar: actorAvatar ?? this.actorAvatar,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

