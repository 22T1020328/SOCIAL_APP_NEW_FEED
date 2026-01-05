import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/user.dart' as app_user;
import '../modules/posts/models/post.dart';
// Service để tương tác với hồ sơ người dùng trên Firebase
class FirebaseProfileService {
  static final FirebaseProfileService _instance =
      FirebaseProfileService._internal();
  factory FirebaseProfileService() => _instance;
  FirebaseProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  

    Future<app_user.User?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;

      return app_user.User.fromJson({
        'id': doc.id,
        'username': data['username'],
        'first_name': data['first_name'],
        'last_name': data['last_name'],
        'email': data['email'],
        'avatar': data['avatar'],
        'bio': data['bio'],
        'is_verified': data['is_verified'] ?? false,
      });
    } catch (e) {
      return null;
    }
  }

    Future<List<Post>> getUserPosts(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 1) 
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      final posts = <Post>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final createdAt = data['created_at'] as Timestamp?;

          posts.add(Post.fromJson({
            'id': doc.id,
            'title': data['title'],
            'description': data['description'],
            'status': data['status'] ?? 1,
            'user_id': data['user_id'],
            'comment_counts': data['comment_counts'] ?? 0,
            'like_counts': data['like_counts'] ?? 0,
            'liked': false,
            'images': data['images'] as List<dynamic>? ?? <dynamic>[],
            'photos': data['photos'] as List<dynamic>? ?? <dynamic>[],
            'created_at': createdAt?.toDate().toIso8601String() ??
                DateTime.now().toIso8601String(),
          }));
        } catch (e) {
          continue;
        }
      }

      return posts;
    } catch (e) {
      return [];
    }
  }

    Future<Map<String, int>> getUserStats(String userId) async {
    try {

      
      final postsSnapshot = await _firestore
          .collection('posts')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 1)
          .count()
          .get();

      
      final followersSnapshot = await _firestore
          .collection('follows')
          .where('followed_user_id', isEqualTo: userId)
          .count()
          .get();

      
      final followingSnapshot = await _firestore
          .collection('follows')
          .where('follower_user_id', isEqualTo: userId)
          .count()
          .get();

      final stats = {
        'posts': postsSnapshot.count ?? 0,
        'followers': followersSnapshot.count ?? 0,
        'following': followingSnapshot.count ?? 0,
      };

      return stats;
    } catch (e) {
      return {
        'posts': 0,
        'followers': 0,
        'following': 0,
      };
    }
  }

  

    Future<bool> updateProfile({
    String? username,
    String? firstName,
    String? lastName,
    String? bio,
  }) async {
    try {
      if (currentUserId == null) return false;

      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (bio != null) updates['bio'] = bio;
      updates['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(currentUserId).update(updates);
      return true;
    } catch (e) {
      return false;
    }
  }

    Future<bool> updateUserProfile({
    required String userId,
    String? username,
    String? firstName,
    String? lastName,
    String? bio,
  }) async {
    try {

      final updates = <String, dynamic>{
        'first_name': firstName ?? '',
        'last_name': lastName ?? '',
        'username': username ?? '',
        'bio': bio ?? '',
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).update(updates);
      return true;
    } catch (e) {
      return false;
    }
  }

    Future<String?> uploadAvatar(XFile imageFile) async {
    try {
      if (currentUserId == null) return null;

      final fileName =
          'avatar_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('avatars/$currentUserId/$fileName');

      
      final UploadTask uploadTask;
      if (kIsWeb) {
        
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes);
      } else {
        
        uploadTask = ref.putData(await imageFile.readAsBytes());
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      
      await _firestore.collection('users').doc(currentUserId).update({
        'avatar': {
          'url': downloadUrl,
          'org_url': downloadUrl,
          'org_width': 300,
          'org_height': 300,
        },
        'updated_at': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  

    Future<bool> followUser(String userIdToFollow) async {
    try {
      if (currentUserId == null || currentUserId == userIdToFollow) {
        return false;
      }

      final followRef = _firestore
          .collection('follows')
          .doc('${currentUserId}_$userIdToFollow');

      
      final doc = await followRef.get();
      if (doc.exists) return true;

      
      await followRef.set({
        'follower_user_id': currentUserId,
        'followed_user_id': userIdToFollow,
        'created_at': FieldValue.serverTimestamp(),
      });

      
      
      
      

      return true;
    } catch (e) {
      return false;
    }
  }

    Future<bool> unfollowUser(String userIdToUnfollow) async {
    try {
      if (currentUserId == null) return false;

      final followRef = _firestore
          .collection('follows')
          .doc('${currentUserId}_$userIdToUnfollow');

      await followRef.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

    Future<bool> isFollowing(String userId) async {
    try {
      if (currentUserId == null) return false;

      final doc = await _firestore
          .collection('follows')
          .doc('${currentUserId}_$userId')
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

    Future<List<app_user.User>> getFollowers(String userId,
      {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('follows')
          .where('followed_user_id', isEqualTo: userId)
          .limit(limit)
          .get();

      final users = <app_user.User>[];
      for (var doc in snapshot.docs) {
        final followerId = doc.data()['follower_user_id'] as String?;
        if (followerId != null) {
          final user = await getUserProfile(followerId);
          if (user != null) users.add(user);
        }
      }

      return users;
    } catch (e) {
      return [];
    }
  }

    Future<List<app_user.User>> getFollowing(String userId,
      {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('follows')
          .where('follower_user_id', isEqualTo: userId)
          .limit(limit)
          .get();

      final users = <app_user.User>[];
      for (var doc in snapshot.docs) {
        final followedId = doc.data()['followed_user_id'] as String?;
        if (followedId != null) {
          final user = await getUserProfile(followedId);
          if (user != null) users.add(user);
        }
      }

      return users;
    } catch (e) {
      return [];
    }
  }
}

