
import '../repos/react_cmt_repo.dart';

class ReactCmtBloc {
  final ReactCmtRepo _repo;

  ReactCmtBloc(this._repo);

  Future<bool> unReact(String commentId) async => _repo.unReact(commentId);

  Future<bool> react(String cmtId, int type) async => _repo.react(cmtId,type);
}

