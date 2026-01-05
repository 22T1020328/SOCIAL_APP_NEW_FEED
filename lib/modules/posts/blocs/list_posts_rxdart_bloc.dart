
import 'dart:async';

import 'package:socail/resources/paging_data_bloc.dart';
import 'package:socail/resources/paging_repo.dart';
import '../../../common/blocs/app_event_bloc.dart';
import '../models/post.dart';
import '../repos/firebase_posts_repo.dart';





















class ListPostsRxDartBloc extends PagingDataBehaviorBloc<Post> {
  Stream<List<Post>?> get postsStream => dataStream;

  late final StreamSubscription<BlocEvent> _subDeletePost;
  late final StreamSubscription<BlocEvent> _onLikeAndUnLikePostSub;
  late final StreamSubscription<BlocEvent> _onCreatPostSub;

  final FirebasePostsRepo _repo;

  ListPostsRxDartBloc() : _repo = FirebasePostsRepo() {
    _subDeletePost = AppEventBloc().listenEvent(
      eventName: EventName.deletePost,
      handler: _deletePost,
    );
    _onCreatPostSub = AppEventBloc().listenEvent(
      eventName: EventName.createPost,
      handler: _onCreatePost,
    );

    _onLikeAndUnLikePostSub = AppEventBloc().listenManyEvents(
      listEventName: [
        EventName.likePostDetail,
        EventName.unLikePostDetail,
      ],
      handler: _onLikeAndUnlikePost,
    );
  }
  void _onCreatePost(BlocEvent evt){
     getPosts(); 
  }

  @override
  Future<void> getData({Map<String, dynamic>? queryObj}) async {
    return getPosts();
  }

  @override
  Future<void> refresh() async {
    return getPosts();
  }

  Future<void> getPosts() async {
    
    
    if (isLoadingSubject.stream.value) {
      return;
    }
    if (!isLoadingSubject.isClosed) {
      isLoadingSubject.sink.add(true);
    }

    try {
      final posts = await _repo.getPosts();
      if (!dataSubject.isClosed) {
        dataSubject.sink.add(posts);
      }
    } catch (e) {
      if (!dataSubject.isClosed) {
        dataSubject.sink.addError(e);
      }
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!isLoadingSubject.isClosed) {
          isLoadingSubject.sink.add(false);
        }
      });
    }
  }

  void _deletePost(BlocEvent evt) {
    final value = evt.value;

    if (value is String && !dataSubject.isClosed) {
      dataSubject.sink.add(dataValue!.where((e) => e.id != value).toList());
    }
  }

  void _onLikeAndUnlikePost(BlocEvent evt) {
    final oldPosts = dataValue ?? [];

    final index = oldPosts.indexWhere((p) => p.id == evt.value);

    if(index == -1){
      return;
    }

    final post = oldPosts[index];


    final likeCount = post.likeCounts;
    final eventIsLike = [EventName.likePostDetail].contains(evt.name);
    final likeCountNew = eventIsLike ? likeCount! + 1 : likeCount! - 1;

    post
      ..likeCounts = likeCountNew
      ..liked = eventIsLike;

    oldPosts[index] = post;

    if (!dataSubject.isClosed) {
      dataSubject.sink.add(oldPosts.toList());
    }
  }

  @override
  void dispose() {
    _subDeletePost.cancel();
    _onLikeAndUnLikePostSub.cancel();
    _onCreatPostSub.cancel();
    super.dispose();
  }

  @override
  PagingRepo get dataRepo => throw UnimplementedError('Using Firebase, not PagingRepo');
}

