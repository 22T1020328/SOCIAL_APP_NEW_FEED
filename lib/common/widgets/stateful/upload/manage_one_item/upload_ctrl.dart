
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socail/common/widgets/stateful/upload/manage_one_item/upload_value.dart';

class UploadController extends ValueNotifier<UploadValue>{
  UploadController(): super(UploadValue());
  String? get uri => value.uri;
  double? get progress => value.progress;
  File? get oriFile => value.oriFile;

  set uri(String? uri){
    value = value.copyWith(uri: uri);
  }
  set progress(double? progress){
    value = value.copyWith(progress:progress);
  }
  set oriFile(File? oriFile){
    value = value.copyWith(oriFile: oriFile);
  }

  void clear(){
    value = UploadValue();
  }


}

