import 'package:socail/modules/comment/models/comment.dart';
import '../../../services/firebase_service.dart';

class FirebaseCommentsRepo {
  final _firebaseService = FirebaseService();
  final String postId;

  FirebaseCommentsRepo(this.postId);

  Future<List<Comment>?> getComments() async {
    try {
      final response = await _firebaseService.getComments(postId: postId);

      if (response['code'] != 200) {
        return null;
      }

      
      final comments = response['data'] as List<Comment>;
      if (comments.isNotEmpty) {
      }
      return comments;
    } catch (e) {
      return null;
    }
  }
}

