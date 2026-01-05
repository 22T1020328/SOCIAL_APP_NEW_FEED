import 'package:socail/common/blocs/app_event_bloc.dart';

import '../repos/firebase_create_post_repo.dart';

class CreatePostBloc {
  Future<bool> createPost(String des, List<String> imageUrls) async {
    try {
      final data = {
        "description": des,
        "img_upload_ids": imageUrls, 
      };

      final res = await FirebaseCreatePostRepo().postData(data);
      if (res) {
        AppEventBloc().emitEvent(BlocEvent(EventName.createPost));
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updatePost(
      String postId, String des, List<String> imageUrls) async {
    try {
      final data = {
        "post_id": postId,
        "description": des,
        "img_upload_ids": imageUrls,
      };

      final res = await FirebaseCreatePostRepo().updateData(data);
      if (res) {
        AppEventBloc().emitEvent(BlocEvent(EventName.createPost));
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }
}

