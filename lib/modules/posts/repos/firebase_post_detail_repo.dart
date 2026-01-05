import '../../../services/firebase_service.dart';
import '../models/post.dart';

class FirebasePostDetailRepo {
  final _firebaseService = FirebaseService();

  Future<Post?> getPost(String id) async {
    try {
      final response = await _firebaseService.getPost(id);

      if (response['code'] != 200) {
        return null;
      }

      
      final data = response['data'] as Map<String, dynamic>;
      return Post.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}

