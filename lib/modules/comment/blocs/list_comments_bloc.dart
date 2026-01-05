
import 'package:rxdart/rxdart.dart';
import 'package:socail/modules/comment/models/comment.dart';
import '../../../providers/bloc_provider.dart';

class ListCommentsBloc extends BlocBase {
  final dynamic _listCmtRepo;

  final _listCmtCtrl = BehaviorSubject<List<Comment>?>();
  Stream<List<Comment>?> get listCmtStream =>
      _listCmtCtrl.stream.map(transformData);
  int get currentLen => _listCmtCtrl.stream.value?.length ?? 0;


  ListCommentsBloc(this._listCmtRepo);

  List<Comment> transformData(List<Comment>? list) {
    if (list == null || list.isEmpty) {
      return [];
    }

    var result = <Comment>[];

    for (final cmt in list) {
      result = [cmt, ...result];
    }

    return result;
  }

  Future<void> getComments() async {
    try {
      final res = await _listCmtRepo.getComments() as List<Comment>?;
      if (res != null) {
        
        if (res.isNotEmpty) {
        }
        _listCmtCtrl.sink.add(res);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _listCmtCtrl.close();
  }
}

