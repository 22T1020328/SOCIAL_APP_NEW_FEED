import '../../../services/firebase_service.dart';

class ReactCmtRepo {
  final String postId;
  final _firebaseService = FirebaseService();

  ReactCmtRepo(this.postId);

  Future<bool> unReact(String commentId) async {
    try {
      return await _firebaseService.unlikeComment(commentId);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> react(String cmtId, int type) async {
    try {
      
      if (type == 0 || type < 0) {
        return await unReact(cmtId);
      } else {
        return await _firebaseService.likeComment(cmtId);
      }
    } catch (e) {
      rethrow;
    }
  }
}

