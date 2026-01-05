import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../modules/posts/models/post.dart';
// Service để tìm kiếm users và posts trên Firebase
class FirebaseSearchService {
  static final FirebaseSearchService _instance = FirebaseSearchService._internal();
  factory FirebaseSearchService() => _instance;
  FirebaseSearchService._internal();

  final _firestore = FirebaseFirestore.instance;

          Future<List<User>> searchUsers(String query, {int limit = 20}) async {
    try {
      if (query.trim().isEmpty) return [];

      final queryLower = query.toLowerCase();

      
      
      
      final snapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: 1)
          .limit(100) 
          .get();

      final users = <User>[];
      
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          final user = User.fromJson(data);

          
          final username = (user.username ?? '').toLowerCase();
          final firstName = (user.firstName ?? '').toLowerCase();
          final lastName = (user.lastName ?? '').toLowerCase();
          final displayName = user.displayName.toLowerCase();
          final fullName = '$firstName $lastName'.toLowerCase();

          
          
          
          
          final queryWords = queryLower.split(' ').where((w) => w.isNotEmpty).toList();
          
          bool matches = false;
          
          
          if (username.contains(queryLower) ||
              firstName.contains(queryLower) ||
              lastName.contains(queryLower) ||
              displayName.contains(queryLower) ||
              fullName.contains(queryLower)) {
            matches = true;
          }
          
          
          if (!matches && queryWords.length > 1) {
            bool allWordsMatch = queryWords.every((word) {
              return username.contains(word) ||
                     firstName.contains(word) ||
                     lastName.contains(word) ||
                     displayName.contains(word);
            });
            if (allWordsMatch) matches = true;
          }

          if (matches) {
            users.add(user);
          }

          if (users.length >= limit) break;
        } catch (e) {
        }
      }

      return users;
    } catch (e) {
      return [];
    }
  }

          Future<List<Post>> searchPosts(String query, {int limit = 20}) async {
    try {
      if (query.trim().isEmpty) return [];

      final queryLower = query.toLowerCase();

      
      final snapshot = await _firestore
          .collection('posts')
          .where('status', isEqualTo: 1)
          .orderBy('created_at', descending: true)
          .limit(100) 
          .get();

      final posts = <Post>[];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;

          
          if (data['created_at'] != null && data['created_at'] is! String) {
            final timestamp = data['created_at'];
            data['created_at'] = timestamp.toDate().toIso8601String();
          }

          
          final userId = data['user_id'] as String?;
          if (userId != null) {
            final userDoc = await _firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              userData?['id'] = userDoc.id;
              data['user'] = userData;
            }
          }

          
          if (data['images'] != null && data['images'] is List) {
            final imagesList = data['images'] as List;
            data['images'] = imagesList.map((img) {
              if (img is Map) {
                return Map<String, dynamic>.from(img);
              }
              return img;
            }).toList();
          }

          final post = Post.fromJson(data);

          
          final title = (post.title ?? '').toLowerCase();
          final description = (post.description ?? '').toLowerCase();
          final userName = (post.user?.displayName ?? '').toLowerCase();

          if (title.contains(queryLower) || 
              description.contains(queryLower) ||
              userName.contains(queryLower)) {
            posts.add(post);
          }

          if (posts.length >= limit) break;
        } catch (e) {
        }
      }

      return posts;
    } catch (e) {
      return [];
    }
  }

    Future<Map<String, dynamic>> searchAll(String query, {int limit = 10}) async {
    try {
      final results = await Future.wait([
        searchUsers(query, limit: limit),
        searchPosts(query, limit: limit),
      ]);

      return {
        'users': results[0],
        'posts': results[1],
      };
    } catch (e) {
      return {
        'users': <User>[],
        'posts': <Post>[],
      };
    }
  }
}

