import '../../../services/firebase_service.dart';
import '../../../utils/model_type.dart';

abstract class CanLikeRepo {
  Future<bool> like(String id);
  Future<bool> unlike(String id);
}

class FirebaseLikeRepo implements CanLikeRepo {
  final _firebaseService = FirebaseService();
  final ModelType type;

  FirebaseLikeRepo(this.type);

  @override
  Future<bool> like(String id) async {
    try {
      if (type == ModelType.post) {
        return await _firebaseService.likePost(id);
      } else {
        return await _firebaseService.likeComment(id);
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> unlike(String id) async {
    try {
      if (type == ModelType.post) {
        return await _firebaseService.unlikePost(id);
      } else {
        return await _firebaseService.unlikeComment(id);
      }
    } catch (e) {
      return false;
    }
  }
}

