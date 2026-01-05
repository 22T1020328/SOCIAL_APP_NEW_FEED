import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../manage_one_item/upload_ctrl.dart';
class UploadItem extends StatefulWidget {
  final UploadController controller;
  final Widget? placeHolder;
  final VoidCallback onDelete;
  final bool showDeleteButton;
  const UploadItem({Key? key,
  required this.controller,
  this.placeHolder,
  required this.onDelete,
  this.showDeleteButton = true}) : super(key: key);

  @override
  State<UploadItem> createState() => _UploadItemState();
}

class _UploadItemState extends State<UploadItem> {

  @override
  initState(){
    super.initState();
    widget.controller.addListener(_didChangeUploadValue);
  }
  @override
  void didUpdateWidget(UploadItem oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.controller!=oldWidget.controller){
      oldWidget.controller.removeListener(_didChangeUploadValue);
      widget.controller.addListener(_didChangeUploadValue);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeUploadValue);
    super.dispose();
  }
  void _didChangeUploadValue(){
    setState((){

    });
  }

  @override
  Widget build(BuildContext context) {
    
    if (widget.controller.uri != null && widget.controller.uri!.isNotEmpty) {
      return Stack(
        children: [
          CachedNetworkImage(
            imageUrl: widget.controller.uri!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (_, __) => widget.placeHolder ?? Container(
              color: const Color(0xff4A4A4A),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
          _buildProgressOverlay(),
        ],
      );
    }

    
    if (widget.controller.oriFile != null) {
      return Stack(
        children: [
          Image.file(
            widget.controller.oriFile!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          _buildProgressOverlay(),
        ],
      );
    }

    
    return Stack(
      children: [
        widget.placeHolder ?? Container(
          color: const Color(0xff4A4A4A),
        ),
        _buildProgressOverlay(),
      ],
    );
  }

  Widget _buildProgressOverlay() {
    
    final isUploading = widget.controller.progress != null && 
                        widget.controller.progress! < 1.0;
    
    return Stack(
      children: [
        if (isUploading)
          Container(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
          ),
        if(showCircular())
          Center(
            child: Theme(
              data: ThemeData(
                colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Theme.of(context).canvasColor)
              ),
              child: CircularProgressIndicator(
                value: widget.controller.progress,
              ),
            ),
          ),
        if(widget.showDeleteButton)
          Positioned(
            top: -8,
            right: -5,
            child: ButtonTheme(
              minWidth: 20,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.transparent)),
                ),
                onPressed: widget.onDelete,
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 16,
                ),
              ),
            ),
          )
      ],
    );
  }
  bool showCircular(){
    return widget.controller.progress!=null && widget.controller.progress !=1.0;
  }
}

