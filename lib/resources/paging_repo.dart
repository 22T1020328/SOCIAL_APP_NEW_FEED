



import '../models/paging.dart';

abstract class PagingRepo {
  String get url;
  bool get isFirstPage => true;
  
  Future<Paging?> fetchData(int page) async {
    throw UnimplementedError('Use Firebase Firestore pagination instead');
  }
  
  Future<Paging?> getData({Map<String, dynamic>? queryObj}) async {
    throw UnimplementedError('Use Firebase Firestore pagination instead');
  }
  
  void refresh() {
    throw UnimplementedError('Use Firebase Firestore pagination instead');
  }
}

