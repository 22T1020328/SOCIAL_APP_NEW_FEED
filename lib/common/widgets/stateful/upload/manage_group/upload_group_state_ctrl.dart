
import 'package:flutter/material.dart';
import 'package:socail/common/widgets/stateful/upload/manage_group/upload_group_value.dart';
import '../widgets/image_upload_item.dart';

class UploadGroupStateController extends ValueNotifier<UploadGroupValue>{
  UploadGroupStateController(): super( const UploadGroupValue(<ImageUploadItem>[]));
  set sate(UploadGroupValue state){
    value = state;
  }

}

