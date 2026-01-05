import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socail/common/widgets/stateful/upload/manage_group/upload_group_state_ctrl.dart';
import 'package:socail/common/widgets/stateful/upload/manage_group/upload_group_value.dart';
import 'package:socail/common/widgets/stateful/upload/widgets/upload_item.dart';
import 'package:socail/services/firebase_storage_service.dart';
import 'package:socail/modules/posts/models/picture.dart';


import 'package:flutter/src/widgets/framework.dart';

import 'image_upload_item.dart';

class ImageUploadGroup extends StatefulWidget {
  final int maxImage;
  final List<ImageUploadItem> listImages;
  final String folder;
  final bool isFulGrid;
  final void Function(UploadGroupValue) onValueChange;

  const ImageUploadGroup(
      {Key? key,
      this.maxImage = 5,
      required this.listImages,
      required this.onValueChange,
      this.folder = "post",
      this.isFulGrid = true})
      : super(key: key);

  @override
  State<ImageUploadGroup> createState() => _ImageUploadGroupState();
}

class _ImageUploadGroupState extends State<ImageUploadGroup> {
  
  
  final controller = UploadGroupStateController();
  List<ImageUploadItem> _listImageParam = <ImageUploadItem>[];
  int maxImageInRow = 3;
  int spacing = 8;
  
  double aspecRatio = 0.75;
  int get maxImage => widget.maxImage;
  int get realMaxImage => maxImage - _listImageParam.where((e) => e.asset==null).length;
  bool get isReady => _listImageParam.where((e) => e.id =="").isEmpty;
  
  
  
  
  @override
  initState(){
    super.initState();
    _listImageParam = widget.listImages;
    controller.addListener(_didChangeValue);
  }
  @override
  dispose(){
    controller.removeListener(_didChangeValue);
    super.dispose();
  }
  void _didChangeValue(){
    widget.onValueChange(controller.value);
  }
  @override
  Widget build(BuildContext context) {
    
    
    
    
    

    return buildGridView();
  }
  Widget buildGridView(){
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: maxImageInRow,
          childAspectRatio: aspecRatio,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8
        ),
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16.0),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.isFulGrid?maxImage:min(_listImageParam.length+1,maxImage),
        itemBuilder: (context, index){
          if(widget.isFulGrid){
            if(index < _listImageParam.length){
              return buildItemImage(image: _listImageParam[index], index: index);
            }else{
              return buildItemAddImage(index);
            }
          }else{
            if(index < _listImageParam.length){
              return buildItemImage(image: _listImageParam[index], index: index);
            }
            if(index == _listImageParam.length)return buildItemAddImage(index);
            return Container();
          }
        }
        );

  }
  Widget buildItemImage({required ImageUploadItem image,required int index}){
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey,width: 1)
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: UploadItem(
              controller: image.controller!,
              onDelete: ()=>removeImage(index),
              showDeleteButton: true,
              placeHolder: image.placeHolder,
            ),
          ),
        )
      ],
    );
  }
  void removeImage(int index){
    final imgUplItem = _listImageParam[index];
    imgUplItem.cancelToken!.cancel;
    _listImageParam.removeAt(index);
    setState((){});
    controller.value = controller.value.withValue(_listImageParam);
  }
  void upLoadImage(ImageUploadItem item)async{
    try{
      if (item.asset == null) {
        throw Exception('No image file to upload');
      }

      
      final storageService = FirebaseStorageService();
      
      final result = await storageService.uploadXFile(
        item.asset!,
        widget.folder,
        onProgress: (progress) {
          item.controller!.progress = progress;
          if (mounted) {
            setState(() {});
          }
        },
      );

      if (result == null) {
        throw Exception('Upload failed');
      }

      
      item.id = result['id']!;
      item.picture = Picture(
        url: result['url'],
        orgUrl: result['url'],
      );
      
      
      
      
      item.controller!.progress = 1.0;
      controller.value = controller.value.withValue(_listImageParam);
      
      if (mounted) {
        setState(() {});
      }

    }catch(e){
      debugPrint('Upload error: $e');
      item.setError(e.toString());
      final idx = _listImageParam.indexOf(item);
      if (idx != -1) {
        removeImage(idx);
      }
    }
  }

  Widget buildItemAddImage(int index) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      color: Theme.of(context).primaryColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: ()async{
          await chooseAndUploadImage();
    },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: 5.0,
            left: 5.0,
            child: Text('${index+1}'),
          ),
          const Positioned(
            top: 5.0,
            right: 5.0,
            child: Material(
              elevation: 3.0,
              shape: CircleBorder(),
              child: Icon(
                Icons.add_circle,
                size: 25,
              ),
            ),
          )
        ],

      ),
      ),
    );
  }
  Future<void> chooseAndUploadImage() async {
    
    List<XFile> resultList = [];

    var localListImg = <ImageUploadItem>[];

    
    if (!kIsWeb) {
      final currentStatus = await Permission.photos.status;

      if (currentStatus == PermissionStatus.denied ||
          currentStatus == PermissionStatus.restricted) {
        await Permission.photos.request();
      } else if (currentStatus == PermissionStatus.permanentlyDenied) {
        openAppSettings();
        return;
      }
    }
    
    final ImagePicker _picker = ImagePicker();

    try {
      final List<XFile> pickedFileList = await _picker.pickMultiImage();
      if(pickedFileList.isNotEmpty){
        setState((){
          resultList = pickedFileList;

        });
        
        }

      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      if (resultList.isEmpty) return;

      for (int i = 0; i < resultList.length; i++) {
        var r = resultList[i];

        String? imageName = r.name;

        if (_listImageParam.isNotEmpty) {
          var foundIdx =
          (_listImageParam.indexWhere((x) => x.name == imageName));

          if (foundIdx != -1) {
            localListImg.add(_listImageParam[foundIdx]);
            continue;
          }
        }

        
        var imageData = await r.readAsBytes();
        var placeHolder = Image.memory(imageData);
        ImageUploadItem imageParam =
        ImageUploadItem(r, imageName, placeHolder);
        localListImg.add(imageParam);

        upLoadImage(imageParam);
      }

      _listImageParam = [
        ..._listImageParam.where((e) => e.asset == null).toList(),
        ...localListImg
      ];
      
      controller.value = controller.value.withValue(_listImageParam);
    } on Exception catch (e) {
      debugPrint('$e');
    }

    
    
    
    if (!mounted) return;

    if (resultList.isNotEmpty) {
      setState(() {});

      final copyList = _listImageParam.toList();

      for (int i = 0; i < copyList.length; i++) {
        if (i >= _listImageParam.length) continue;
        if (_listImageParam[i].state == "init") upLoadImage(_listImageParam[i]);
      }
    }
  }
}

