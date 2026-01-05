import '../../../services/firebase_service.dart';
import '../models/post.dart';

class FirebasePostsRepo {
  final _firebaseService = FirebaseService();

  Future<List<Post>?> getPosts() async {
    try {
      final response = await _firebaseService.getPosts();

      if (response['code'] != 200) {
        return null;
      }

      
      return response['data'] as List<Post>;
    } catch (e) {
      rethrow;
    }
  }
}

