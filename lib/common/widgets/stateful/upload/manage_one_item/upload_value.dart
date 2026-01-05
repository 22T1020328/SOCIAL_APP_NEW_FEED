
import 'dart:io';

class UploadValue{
  String? uri;
  double? progress;
  File? oriFile;

  UploadValue({this.uri, this.progress, this.oriFile});
  UploadValue copyWith({String? uri, double? progress, File? oriFile}){
    return UploadValue(
      oriFile: oriFile ?? this.oriFile,
      uri: uri ?? this.uri,
      progress: progress ?? this.progress
    );
  }
}

