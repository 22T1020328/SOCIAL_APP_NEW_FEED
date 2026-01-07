import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';
import '../modules/posts/models/post.dart';
import '../modules/posts/models/picture.dart';
import '../modules/comment/models/comment.dart';
import 'firebase_notification_service.dart';

//Service để tương tác với Firebase
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final _notificationService = FirebaseNotificationService();

  String? get currentUserId => _auth.currentUser?.uid;

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User not found');
      }

      final token = await user.getIdToken();

      return {
        'code': 200,
        'data': {
          'access_token': token,
          'refresh_token': await user.getIdToken(true),
          'oauth_id': user.uid,
          'expires_in': 3600,
          'is_new': credential.additionalUserInfo?.isNewUser ?? false,
          'has_username_password': true,
        },
      };
    } on auth.FirebaseAuthException catch (e) {
      return {'code': 400, 'message': e.message};
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      final displayName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
      final avatarSeed = displayName.isNotEmpty ? displayName : username;
      final avatarUrl =
          'https://api.dicebear.com/7.x/avataaars/png?seed=${Uri.encodeComponent(avatarSeed)}';

      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'is_verified': false,
        'avatar': {
          'url': avatarUrl,
          'org_url': avatarUrl,
          'org_width': 150,
          'org_height': 150,
        },
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      final token = await user.getIdToken();

      return {
        'code': 200,
        'data': {
          'access_token': token,
          'refresh_token': await user.getIdToken(true),
          'oauth_id': user.uid,
          'expires_in': 3600,
          'is_new': true,
          'has_username_password': true,
        },
      };
    } on auth.FirebaseAuthException catch (e) {
      return {'code': 400, 'message': e.message};
    }
  }

  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        final authUser = _auth.currentUser;
        if (authUser != null && authUser.uid == userId) {
          await _createUserFromAuth(authUser);

          final newDoc = await _firestore.collection('users').doc(userId).get();
          if (newDoc.exists) {
            return _parseUserFromDoc(newDoc);
          }
        }
        return null;
      }

      final data = doc.data();

      if (data != null &&
          (data['avatar'] == null ||
              data['avatar']['url'] == null ||
              data['avatar']['url'].toString().isEmpty)) {
        await _createAvatarForUser(userId, data);

        final updatedDoc = await _firestore
            .collection('users')
            .doc(userId)
            .get();
        return _parseUserFromDoc(updatedDoc);
      }

      return _parseUserFromDoc(doc);
    } catch (e) {
      return null;
    }
  }

  Future<void> _createAvatarForUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final firstName = userData['first_name']?.toString() ?? '';
      final lastName = userData['last_name']?.toString() ?? '';
      final username = userData['username']?.toString() ?? '';
      final displayName = '$firstName $lastName'.trim();
      final avatarSeed = displayName.isNotEmpty
          ? displayName
          : (username.isNotEmpty ? username : 'User');

      final avatarUrl =
          'https://api.dicebear.com/7.x/avataaars/png?seed=${Uri.encodeComponent(avatarSeed)}';

      await _firestore.collection('users').doc(userId).update({
        'avatar': {
          'url': avatarUrl,
          'org_url': avatarUrl,
          'org_width': 150,
          'org_height': 150,
        },
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  /// Hàm parse User từ DocumentSnapshot
  User? _parseUserFromDoc(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // Tạo userData với tất cả các trường
      final userData = <String, dynamic>{
        'id': doc.id,
        'username': data['username'],
        'first_name': data['first_name'],
        'last_name': data['last_name'],
        'email': data['email'],
        'avatar': data['avatar'],
        'bio': data['bio'],
        'is_verified': data['is_verified'] ?? false,
        'is_admin': data['is_admin'] ?? false,
      };

      final user = User.fromJson(userData);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> _createUserFromAuth(auth.User authUser) async {
    try {
      final displayName =
          authUser.displayName ?? authUser.email?.split('@')[0] ?? 'User';
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : displayName;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final avatarUrl =
          'https://api.dicebear.com/7.x/avataaars/png?seed=${Uri.encodeComponent(displayName)}';

      await _firestore.collection('users').doc(authUser.uid).set({
        'id': authUser.uid,
        'username':
            authUser.email?.split('@')[0] ??
            'user_${authUser.uid.substring(0, 8)}',
        'first_name': firstName,
        'last_name': lastName,
        'email': authUser.email,
        'is_verified': false,
        'avatar': {
          'url': avatarUrl,
          'org_url': avatarUrl,
          'org_width': 150,
          'org_height': 150,
        },
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getPosts({
    int limit = 50,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      final posts = <Post>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          final postData = <String, dynamic>{
            'id': doc.id,
            'title': data?['title'],
            'description': data?['description'],
            'status': data?['status'] ?? 1,
            'user_id': data?['user_id'],
            'comment_counts': data?['comment_counts'] ?? 0,
            'like_counts': data?['like_counts'] ?? 0,
            'liked': false,
          };

          try {
            final createdAt = data?['created_at'];
            if (createdAt is Timestamp) {
              postData['created_at'] = createdAt.toDate().toIso8601String();
            } else if (createdAt != null) {
              postData['created_at'] = createdAt.toString();
            }
          } catch (e) {
            postData['created_at'] = DateTime.now().toIso8601String();
          }

          if (data?['images'] != null && data!['images'] is List) {
            final imagesList = data['images'] as List;
            postData['images'] = imagesList
                .map((img) {
                  if (img is Map) {
                    final imageMap = {
                      'url': img['url']?.toString(),
                      'org_url':
                          img['org_url']?.toString() ?? img['url']?.toString(),
                      'org_width': img['org_width'],
                      'org_height': img['org_height'],
                    };
                    return imageMap;
                  }
                  return null;
                })
                .where((img) => img != null)
                .toList();
          } else {
            postData['images'] = <dynamic>[];
          }

          postData['photos'] = <dynamic>[];

          if (postData['user_id'] != null) {
            final user = await getUser(postData['user_id'] as String);
            if (user != null) {
              postData['user'] = <String, dynamic>{
                'id': user.id,
                'username': user.username,
                'first_name': user.firstName,
                'last_name': user.lastName,
                'avatar': user.avatar?.toJson(),
                'bio': user.bio,
                'is_verified': user.isVerified,
              };
            }
          }

          if (currentUserId != null) {
            final liked = await checkPostLiked(doc.id, currentUserId!);
            postData['liked'] = liked;
          }

          posts.add(Post.fromJson(postData));
        } catch (e) {
          continue;
        }
      }

      return {
        'code': 200,
        'data': posts,
        'paging': {
          'limit': limit,
          'total': snapshot.size,
          'has_next': snapshot.docs.length >= limit,
        },
      };
    } catch (e) {
      return {'code': 500, 'message': 'Error getting posts: $e'};
    }
  }

  Future<Map<String, dynamic>> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) {
        return {'code': 404, 'message': 'Post not found'};
      }

      final data = doc.data();
      final postData = <String, dynamic>{
        'id': doc.id,
        'title': data?['title'],
        'description': data?['description'],
        'status': data?['status'] ?? 1,
        'user_id': data?['user_id'],
        'comment_counts': data?['comment_counts'] ?? 0,
        'like_counts': data?['like_counts'] ?? 0,
        'liked': false,
        'images': data?['images'] as List<dynamic>? ?? <dynamic>[],
        'photos': data?['photos'] as List<dynamic>? ?? <dynamic>[],
      };

      try {
        final createdAt = data?['created_at'];
        if (createdAt is Timestamp) {
          postData['created_at'] = createdAt.toDate().toIso8601String();
        } else if (createdAt != null) {
          postData['created_at'] = createdAt.toString();
        }
      } catch (e) {
        postData['created_at'] = DateTime.now().toIso8601String();
      }

      if (postData['user_id'] != null) {
        final user = await getUser(postData['user_id'] as String);
        if (user != null) {
          postData['user'] = <String, dynamic>{
            'id': user.id,
            'username': user.username,
            'first_name': user.firstName,
            'last_name': user.lastName,
            'avatar': user.avatar?.toJson(),
            'is_verified': user.isVerified,
          };
        }
      }

      if (currentUserId != null) {
        final liked = await checkPostLiked(postId, currentUserId!);
        postData['liked'] = liked;
      }

      return {'code': 200, 'data': postData};
    } catch (e) {
      return {'code': 500, 'message': 'Error getting post: $e'};
    }
  }

  Future<Map<String, dynamic>> createPost({
    required String title,
    String? description,
    List<Picture>? images,
    List<String>? imageUrls,
  }) async {
    try {
      if (currentUserId == null) {
        return {'code': 401, 'message': 'User not authenticated'};
      }

      List<Picture> finalImages = images ?? [];
      if (imageUrls != null && imageUrls.isNotEmpty) {
        finalImages = imageUrls
            .map((url) => Picture(url: url, orgUrl: url))
            .toList();
      }

      final postRef = _firestore.collection('posts').doc();
      final postData = {
        'id': postRef.id,
        'user_id': currentUserId,
        'title': title,
        'description': description,
        'images': finalImages.map((img) => img.toJson()).toList(),
        'status': 1,
        'comment_counts': 0,
        'like_counts': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await postRef.set(postData);

      return {'code': 200, 'data': postData};
    } catch (e) {
      return {'code': 500, 'message': 'Error creating post: $e'};
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      if (currentUserId == null) return false;

      final likeRef = _firestore
          .collection('post_likes')
          .doc('${postId}_$currentUserId');

      final likeDoc = await likeRef.get();
      if (likeDoc.exists) {
        return true;
      }

      final postDoc = await _firestore.collection('posts').doc(postId).get();
      final postOwnerId = postDoc.data()?['user_id'] as String?;

      await likeRef.set({
        'id': likeRef.id,
        'post_id': postId,
        'user_id': currentUserId,
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('posts').doc(postId).update({
        'like_counts': FieldValue.increment(1),
      });

      if (postOwnerId != null && postOwnerId != currentUserId) {
        await _notificationService.createPostLikeNotification(
          postId: postId,
          postOwnerId: postOwnerId,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unlikePost(String postId) async {
    try {
      if (currentUserId == null) return false;

      final likeRef = _firestore
          .collection('post_likes')
          .doc('${postId}_$currentUserId');

      final likeDoc = await likeRef.get();
      if (!likeDoc.exists) {
        return true;
      }

      // Kiểm tra like_counts trước khi giảm để tránh âm
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      final currentLikeCount = postDoc.data()?['like_counts'] as int? ?? 0;
      
      if (currentLikeCount <= 0) {
        // Nếu đã về 0 thì chỉ xóa like record, không giảm nữa
        await likeRef.delete();
        return true;
      }

      await likeRef.delete();

      await _firestore.collection('posts').doc(postId).update({
        'like_counts': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkPostLiked(String postId, String userId) async {
    try {
      final docId = '${postId}_$userId';
      final likeDoc = await _firestore
          .collection('post_likes')
          .doc(docId)
          .get();
      final exists = likeDoc.exists;
      return exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> updatePost({
    required String postId,
    String? description,
    List<String>? imageUrls,
  }) async {
    try {
      if (currentUserId == null) {
        return {'code': 401, 'message': 'User not authenticated'};
      }

      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (!postDoc.exists) {
        return {'code': 404, 'message': 'Post not found'};
      }

      final postData = postDoc.data()!;
      if (postData['user_id'] != currentUserId) {
        return {'code': 403, 'message': 'You can only edit your own posts'};
      }

      Map<String, dynamic> updateData = {
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (description != null) {
        updateData['description'] = description;
      }

      if (imageUrls != null) {
        final images = imageUrls
            .map((url) => Picture(url: url, orgUrl: url))
            .toList();
        updateData['images'] = images.map((img) => img.toJson()).toList();
      }

      await _firestore.collection('posts').doc(postId).update(updateData);

      return {'code': 200, 'message': 'Post updated successfully'};
    } catch (e) {
      return {'code': 500, 'message': 'Error updating post: $e'};
    }
  }

  Future<Map<String, dynamic>> getComments({
    required String postId,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('post_id', isEqualTo: postId)
          .orderBy('created_at', descending: false)
          .limit(limit)
          .get();

      final comments = <Comment>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();

          if (data['status'] != null && data['status'] != 1) {
            continue;
          }

          final commentData = <String, dynamic>{
            'id': doc.id,
            'content': data['content'],
            'status': data['status'] ?? 1,
            'user_id': data['user_id'],
            'post_id': data['post_id'],
            'like_count': data['like_count'] ?? 0,
            'liked': false,
            if (data['parent_comment_id'] != null)
              'parent_comment_id': data['parent_comment_id'],
          };

          try {
            final createdAt = data['created_at'];
            if (createdAt is Timestamp) {
              commentData['created_at'] = createdAt.toDate().toIso8601String();
            } else if (createdAt is DateTime) {
              commentData['created_at'] = createdAt.toIso8601String();
            } else if (createdAt is String) {
              commentData['created_at'] = createdAt;
            }
          } catch (e) {
            commentData['created_at'] = DateTime.now().toIso8601String();
          }

          if (commentData['user_id'] != null) {
            final user = await getUser(commentData['user_id'] as String);
            if (user != null) {
              commentData['user'] = <String, dynamic>{
                'id': user.id,
                'username': user.username,
                'first_name': user.firstName,
                'last_name': user.lastName,
                'avatar': user.avatar?.toJson(),
                'is_verified': user.isVerified,
              };
            }
          }

          if (currentUserId != null) {
            final liked = await checkCommentLiked(doc.id, currentUserId!);
            commentData['liked'] = liked;
          }

          comments.add(Comment.fromJson(commentData));
        } catch (e) {
          continue;
        }
      }

      return {'code': 200, 'data': comments};
    } catch (e) {
      return {'code': 500, 'message': 'Error getting comments: $e'};
    }
  }

  Future<Map<String, dynamic>> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      if (currentUserId == null) {
        return {'code': 401, 'message': 'User not authenticated'};
      }

      final postDoc = await _firestore.collection('posts').doc(postId).get();
      final postOwnerId = postDoc.data()?['user_id'] as String?;

      final commentRef = _firestore.collection('comments').doc();
      final commentData = {
        'id': commentRef.id,
        'post_id': postId,
        'user_id': currentUserId,
        'content': content,
        'status': 1,
        'like_count': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        if (parentCommentId != null && parentCommentId.isNotEmpty)
          'parent_comment_id': parentCommentId,
      };

      await commentRef.set(commentData);

      await _firestore.collection('posts').doc(postId).update({
        'comment_counts': FieldValue.increment(1),
      });

      if (postOwnerId != null && postOwnerId != currentUserId) {
        await _notificationService.createCommentNotification(
          postId: postId,
          postOwnerId: postOwnerId,
          commentContent: content,
        );
      }

      return {'code': 200, 'data': commentData};
    } catch (e) {
      return {'code': 500, 'message': 'Error creating comment: $e'};
    }
  }

  Future<bool> likeComment(String commentId) async {
    try {
      if (currentUserId == null) return false;

      final likeRef = _firestore
          .collection('comment_likes')
          .doc('${commentId}_$currentUserId');

      final likeDoc = await likeRef.get();
      if (likeDoc.exists) {
        return true;
      }

      final commentDoc = await _firestore
          .collection('comments')
          .doc(commentId)
          .get();
      final commentOwnerId = commentDoc.data()?['user_id'] as String?;
      final postId = commentDoc.data()?['post_id'] as String?;

      await likeRef.set({
        'id': likeRef.id,
        'comment_id': commentId,
        'user_id': currentUserId,
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('comments').doc(commentId).update({
        'like_count': FieldValue.increment(1),
      });

      if (commentOwnerId != null &&
          commentOwnerId != currentUserId &&
          postId != null) {
        await _notificationService.createCommentLikeNotification(
          commentId: commentId,
          commentOwnerId: commentOwnerId,
          postId: postId,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unlikeComment(String commentId) async {
    try {
      if (currentUserId == null) return false;

      final likeRef = _firestore
          .collection('comment_likes')
          .doc('${commentId}_$currentUserId');

      final likeDoc = await likeRef.get();
      if (!likeDoc.exists) {
        return true;
      }

      await likeRef.delete();

      await _firestore.collection('comments').doc(commentId).update({
        'like_count': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkCommentLiked(String commentId, String userId) async {
    try {
      final docId = '${commentId}_$userId';
      final likeDoc = await _firestore
          .collection('comment_likes')
          .doc(docId)
          .get();
      final exists = likeDoc.exists;
      return exists;
    } catch (e) {
      return false;
    }
  }

  // =====================
  // Admin Functions
  // =====================

  /// Lấy danh sách tất cả người dùng (chỉ dành cho admin)
  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('created_at', descending: true)
          .get();

      final users = <User>[];
      for (var doc in snapshot.docs) {
        try {
          final user = _parseUserFromDoc(doc);
          if (user != null) {
            users.add(user);
          }
        } catch (e) {
          // Bỏ qua user có lỗi parse
        }
      }

      return users;
    } catch (e) {
      return [];
    }
  }

  /// Xóa người dùng (chỉ dành cho admin)
  /// LƯU Ý: Hàm này chỉ xóa Firestore data, KHÔNG xóa Firebase Auth account
  /// Vì xóa Auth account yêu cầu user phải đăng nhập gần đây hoặc dùng Admin SDK
  Future<bool> deleteUser(String userId) async {
    try {
      // Xóa tất cả notifications của user
      final notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in notificationsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Xóa tất cả notifications mà user này là actor
      final actorNotificationsSnapshot = await _firestore
          .collection('notifications')
          .where('actor_id', isEqualTo: userId)
          .get();

      for (var doc in actorNotificationsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Xóa tất cả post likes của user
      final postLikesSnapshot = await _firestore
          .collection('post_likes')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in postLikesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Xóa tất cả comment likes của user
      final commentLikesSnapshot = await _firestore
          .collection('comment_likes')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in commentLikesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Xóa tất cả follows (user theo dõi người khác)
      final followingSnapshot = await _firestore
          .collection('follows')
          .where('follower_user_id', isEqualTo: userId)
          .get();

      for (var doc in followingSnapshot.docs) {
        await doc.reference.delete();
      }

      // Xóa tất cả followers (người khác theo dõi user)
      final followersSnapshot = await _firestore
          .collection('follows')
          .where('following_user_id', isEqualTo: userId)
          .get();

      for (var doc in followersSnapshot.docs) {
        await doc.reference.delete();
      }

      // Xóa tất cả payment transactions
      final paymentsSnapshot = await _firestore
          .collection('payment_transactions')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in paymentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Xóa tất cả posts của user
      final postsSnapshot = await _firestore
          .collection('posts')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in postsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Xóa tất cả comments của user
      final commentsSnapshot = await _firestore
          .collection('comments')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Xóa user document (QUAN TRỌNG: Phải xóa cuối cùng)
      await _firestore.collection('users').doc(userId).delete();

      // LƯU Ý: Không thể xóa Firebase Auth account từ đây
      // Nếu cần xóa Auth account, phải dùng Firebase Admin SDK hoặc 
      // yêu cầu user đăng nhập lại để xóa account của chính họ

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle trạng thái verified của user (chỉ dành cho admin)
  Future<bool> toggleUserVerified(String userId, bool isVerified) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'is_verified': isVerified,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
