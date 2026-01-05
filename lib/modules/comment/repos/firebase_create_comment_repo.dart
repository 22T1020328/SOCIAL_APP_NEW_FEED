import '../../../services/firebase_service.dart';

class FirebaseCreateCommentRepo {
  final String postId;
  final _firebaseService = FirebaseService();

  FirebaseCreateCommentRepo(this.postId);

  Future<bool> submitCommentToServer(String content, {String? parentCommentId}) async {
    try {
      final response = await _firebaseService.createComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      );
      return response['code'] == 200;
    } catch (e) {
      rethrow;
    }
  }
}

