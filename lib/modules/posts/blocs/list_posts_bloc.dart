import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../models/post.dart';
import '../repos/firebase_posts_repo.dart';

class ListPostsBloc extends Bloc<String, ListPostsState> {
  ListPostsBloc() : super(ListPostsState()) {
    on<String>(
      (event, emit) async {
        switch (event) {
          case 'getPosts':
            try {
              final res = await FirebasePostsRepo().getPosts();
              if (res != null) {
                emit(ListPostsState(posts: res));
              }
            } catch (e) {
              emit(ListPostsState(error: e));
            }
            break;
          default:
            
            await _search(event, emit);
        }
      },
      transformer: debounce(const Duration(milliseconds: 100)),
    );
  }

  Future<void> _search(String query, Emitter<ListPostsState> emit) async {
    if (query.isEmpty) {
      return;
    }
  }
}


EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class ListPostsState {
  final Object? error;
  final List<Post>? posts;

  final List<String>? tagList;
  final String? tagQuery;

  ListPostsState({
    this.error,
    this.posts,
    this.tagList,
    this.tagQuery,
  });

  ListPostsState copyWith({
    Object? error,
    List<Post>? posts,
    List<String>? tagList,
    String? tagQuery,
  }) =>
      ListPostsState(
        error: error ?? this.error,
        posts: posts ?? this.posts,
        tagList: tagList ?? this.tagList,
        tagQuery: tagQuery ?? this.tagQuery,
      );
}

