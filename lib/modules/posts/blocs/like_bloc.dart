import '../../../providers/bloc_provider.dart';
import '../repos/firebase_like_repo.dart';

class LikeBloc extends BlocBase {
  final CanLikeRepo likeRepo;

  LikeBloc(this.likeRepo);

  Future<bool> like(String id) => likeRepo.like(id);

  Future<bool> unlike(String id) => likeRepo.unlike(id);

  @override
  void dispose() {}
}

