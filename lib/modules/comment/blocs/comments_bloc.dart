

import 'package:socail/common/blocs/app_event_bloc.dart';
import 'package:socail/modules/comment/blocs/react_cmt_bloc.dart';
import 'package:socail/modules/comment/models/comment.dart';

import '../../../providers/bloc_provider.dart';
import '../repos/firebase_create_comment_repo.dart';
import '../repos/firebase_comments_repo.dart';
import '../repos/react_cmt_repo.dart';
import 'create_comment_bloc.dart';
import 'list_comments_bloc.dart';

class CommentBloc extends BlocBase {
  final String postId;
  final ListCommentsBloc _commentsBloc;
  final CreateCommentBloc _createCmtBloc;
  final ReactCmtBloc _reactCmtBloc;
  

  Stream<List<Comment>?> get listCmtStream => _commentsBloc.listCmtStream;

  CommentBloc(this.postId)
      : _commentsBloc = ListCommentsBloc(FirebaseCommentsRepo(postId)),
        _createCmtBloc = CreateCommentBloc(FirebaseCreateCommentRepo(postId)),
        _reactCmtBloc = ReactCmtBloc(ReactCmtRepo(postId));

  Future<void> getComments() async => _commentsBloc.getComments();

  Future<void> writeCmt(String content, {String? parentCommentId}) async {
    try {
      final res = await _createCmtBloc.createCmt(content, parentCommentId: parentCommentId);
      if (res) {
        _commentsBloc.getComments();
        AppEventBloc().emitEvent(const BlocEvent(EventName.createComment));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> react(String id, int type) async{
    try{
      final res = await _reactCmtBloc.react(id, type);
      if(res){
        await getComments();
      }
      return res;
    }catch(e){
      rethrow;
    }
  }

  @override
  void dispose() {}
}

