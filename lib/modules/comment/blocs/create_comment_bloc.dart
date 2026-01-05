
class CreateCommentBloc {
  final dynamic _repo;

  CreateCommentBloc(this._repo);

  Future<bool> createCmt(String content, {String? parentCommentId}) async {
    return await _repo.submitCommentToServer(content, parentCommentId: parentCommentId) as bool;
  }
}

