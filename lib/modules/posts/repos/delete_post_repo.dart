

import '../../../services/firebase_service.dart';

class DeletePostRepo {
  final String postId;
  final _firebaseService = FirebaseService();

  DeletePostRepo(this.postId);

  Future<bool> delete() async {
    try {
      return await _firebaseService.deletePost(postId);
    } catch (e) {
      return false;
    }
  }
}

