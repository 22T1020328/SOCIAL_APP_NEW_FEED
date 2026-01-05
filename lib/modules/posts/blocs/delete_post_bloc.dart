

import '../repos/delete_post_repo.dart';

class DeletePostBloc {

  Future<bool>deletePost(String id)async{
    try{
      return DeletePostRepo(id).delete();
    }catch(e){
      rethrow;
    }
  }
}

