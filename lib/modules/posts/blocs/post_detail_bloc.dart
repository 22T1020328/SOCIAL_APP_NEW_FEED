
import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../common/blocs/app_event_bloc.dart';
import '../../../providers/bloc_provider.dart';
import '../models/post.dart';
import '../repos/firebase_post_detail_repo.dart';
import 'delete_post_bloc.dart';

class PostDetailBloc extends BlocBase{
  final String _postId;
  final deletePostBloc = DeletePostBloc();

  final _postCtrl = BehaviorSubject<Post>();
  Stream<Post> get postsStream => _postCtrl.stream;
  Post get postDetail => _postCtrl.stream.value;
  late final StreamSubscription<BlocEvent> _subCreateCmt;
  late final StreamSubscription<BlocEvent> _subLikeUnlike;

  PostDetailBloc(this._postId){
    _subCreateCmt = AppEventBloc().listenEvent(
        eventName: EventName.createComment,
        handler: _onCreateCmt);
    
    _subLikeUnlike = AppEventBloc().listenManyEvents(
      listEventName: [
        EventName.likePostDetail,
        EventName.unLikePostDetail,
      ],
      handler: _onLikeUnlikePost,
    );
  }

  Future<void> getPost() async {
    try {
      final res = await FirebasePostDetailRepo().getPost(_postId);
      if (res != null) {
        _postCtrl.sink.add(res);
      }
    } catch (e) {
      _postCtrl.sink.addError('Không thể lấy bài viết ngay bây giờ!!!');
    }
  }
  void _onCreateCmt(BlocEvent evt){
    final currentNum = postDetail.commentCounts ??0;
    final newCount = currentNum+1;
    _postCtrl.sink.add(postDetail..commentCounts = newCount);
  }

  void _onLikeUnlikePost(BlocEvent evt) {
    
    
    if (evt.value != _postId) {
      return;
    }

    final currentPost = postDetail;
    final likeCount = currentPost.likeCounts ?? 0;
    final eventIsLike = evt.name == EventName.likePostDetail;
    final newLikeCount = eventIsLike ? likeCount + 1 : likeCount - 1;

    _postCtrl.sink.add(currentPost
      ..likeCounts = newLikeCount
      ..liked = eventIsLike);
  }

  Future<void> deletePost() async {
    try {
      AppEventBloc().emitEvent(BlocEvent(EventName.deletePost,_postId));
      return;
      
      
      
      
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _postCtrl.close();
    _subCreateCmt.cancel();
    _subLikeUnlike.cancel();
  }
}


