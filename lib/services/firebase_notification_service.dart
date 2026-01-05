import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';
//Push notifications với Firebase Cloud Messaging
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  

    Future<void> createPostLikeNotification({
    required String postId,
    required String postOwnerId,
  }) async {
    if (currentUserId == null || currentUserId == postOwnerId) return;

    final actor = await _getUserInfo(currentUserId!);
    if (actor == null) return;

    await _firestore.collection('notifications').add({
      'user_id': postOwnerId,
      'actor_id': currentUserId,
      'actor_name': actor['name'],
      'actor_avatar': actor['avatar'],
      'type': 'like_post',
      'post_id': postId,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

    Future<void> createCommentLikeNotification({
    required String commentId,
    required String commentOwnerId,
    required String postId,
  }) async {
    if (currentUserId == null || currentUserId == commentOwnerId) return;

    final actor = await _getUserInfo(currentUserId!);
    if (actor == null) return;

    await _firestore.collection('notifications').add({
      'user_id': commentOwnerId,
      'actor_id': currentUserId,
      'actor_name': actor['name'],
      'actor_avatar': actor['avatar'],
      'type': 'like_comment',
      'post_id': postId,
      'comment_id': commentId,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

    Future<void> createCommentNotification({
    required String postId,
    required String postOwnerId,
    required String commentContent,
  }) async {
    if (currentUserId == null || currentUserId == postOwnerId) return;

    final actor = await _getUserInfo(currentUserId!);
    if (actor == null) return;

    final truncatedContent = commentContent.length > 50
        ? '${commentContent.substring(0, 50)}...'
        : commentContent;

    await _firestore.collection('notifications').add({
      'user_id': postOwnerId,
      'actor_id': currentUserId,
      'actor_name': actor['name'],
      'actor_avatar': actor['avatar'],
      'type': 'comment',
      'post_id': postId,
      'content': truncatedContent,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

    Future<void> createFollowNotification({
    required String followedUserId,
  }) async {
    if (currentUserId == null || currentUserId == followedUserId) return;

    final actor = await _getUserInfo(currentUserId!);
    if (actor == null) return;

    await _firestore.collection('notifications').add({
      'user_id': followedUserId,
      'actor_id': currentUserId,
      'actor_name': actor['name'],
      'actor_avatar': actor['avatar'],
      'type': 'follow',
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  

    Stream<List<NotificationModel>> getNotificationsStream() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: currentUserId)
        
        
        
        
        .limit(50)
        .snapshots()
        .map((snapshot) {
      
      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final aTime = (a.data()['created_at'] as Timestamp?)?.toDate() ?? DateTime(2000);
          final bTime = (b.data()['created_at'] as Timestamp?)?.toDate() ?? DateTime(2000);
          return bTime.compareTo(aTime); 
        });
      
      return docs.map((doc) {
        final data = doc.data();
        final timestamp = data['created_at'] as Timestamp?;

        return NotificationModel(
          id: doc.id,
          userId: data['user_id'] as String? ?? '',
          actorId: data['actor_id'] as String? ?? '',
          actorName: data['actor_name'] as String? ?? 'Someone',
          actorAvatar: data['actor_avatar'] as String?,
          type: data['type'] as String? ?? 'unknown',
          postId: data['post_id'] as String?,
          commentId: data['comment_id'] as String?,
          content: data['content'] as String?,
          isRead: data['is_read'] as bool? ?? false,
          createdAt: timestamp?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        );
      }).toList();
    });
  }

    Stream<int> getUnreadCountStream() {
    if (currentUserId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: currentUserId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  

    Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'is_read': true,
    });
  }

    Future<void> markAllAsRead() async {
    if (currentUserId == null) return;

    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: currentUserId)
        .where('is_read', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'is_read': true});
    }

    await batch.commit();
  }

    Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

    Future<void> deleteAllNotifications() async {
    if (currentUserId == null) return;

    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: currentUserId)
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  

  Future<Map<String, dynamic>?> _getUserInfo(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final avatar = data['avatar'] as Map<String, dynamic>?;

      return {
        'name': '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim(),
        'avatar': avatar?['url'],
      };
    } catch (e) {
      return null;
    }
  }
}

