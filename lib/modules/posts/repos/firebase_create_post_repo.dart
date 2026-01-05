import '../../../services/firebase_service.dart';
import '../models/picture.dart';

class FirebaseCreatePostRepo {
  final _firebaseService = FirebaseService();

  Future<bool> postData(Map<String, dynamic> data) async {
    try {
      final response = await _firebaseService.createPost(
        title: data['title'] as String? ?? '',
        description: data['description'] as String?,
        images: data['images'] as List<Picture>?,
        imageUrls: data['img_upload_ids'] != null
            ? List<String>.from(data['img_upload_ids'] as List)
            : null,
      );

      return response['code'] == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateData(Map<String, dynamic> data) async {
    try {
      final response = await _firebaseService.updatePost(
        postId: data['post_id'] as String,
        description: data['description'] as String?,
        imageUrls: data['img_upload_ids'] != null
            ? List<String>.from(data['img_upload_ids'] as List)
            : null,
      );

      return response['code'] == 200;
    } catch (e) {
      return false;
    }
  }
}

