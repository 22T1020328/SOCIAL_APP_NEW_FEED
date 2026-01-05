import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socail/common/widgets/stateless/loading_hide_keyboard.dart';
import 'package:socail/values/app_theme.dart';

import '../../../common/widgets/stateful/upload/manage_group/upload_group_value.dart';
import '../../../common/widgets/stateful/upload/widgets/image_upload_group.dart';
import '../../../common/widgets/stateful/upload/widgets/image_upload_item.dart';
import '../blocs/create_post_bloc.dart';
import '../models/post.dart';

class CreatePostPage extends StatefulWidget {
  final Post? post;
  const CreatePostPage({Key? key, this.post}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late final TextEditingController _desCtrl;
  late final FocusNode _focusNodeDes;
  bool isLoading = false;
  UploadGroupValue _currentGroupUploadValue =
      const UploadGroupValue(<ImageUploadItem>[]);
  final _createPostBloc = CreatePostBloc();

  @override
  void initState() {
    super.initState();
    _desCtrl = TextEditingController(text: widget.post?.description ?? '');
    _focusNodeDes = FocusNode();
  }

  @override
  void dispose() {
    _desCtrl.dispose();
    _focusNodeDes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.post != null ? 'Chỉnh sửa bài viết' : 'Tạo bài viết',
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            )),
      ),
      body: LoadingHideKeyboard(
        isLoading: isLoading,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Text(
                      'Bạn đang nghĩ gì?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        color: Colors.grey[50],
                      ),
                      child: TextField(
                        controller: _desCtrl,
                        focusNode: _focusNodeDes,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Chia sẻ suy nghĩ hoặc trải nghiệm của bạn...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        autocorrect: false,
                        minLines: 4,
                        maxLines: 10,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(500),
                        ],
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),

                    
                    Text(
                      'Thêm hình ảnh',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.grey[300]!, width: 1.5),
                        color: Colors.grey[50],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: ImageUploadGroup(
                        isFulGrid: false,
                        onValueChange: (UploadGroupValue value) {
                          setState(() {
                            _currentGroupUploadValue = value;
                          });
                        },
                        listImages: const [],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Bạn có thể tải lên tối đa 5 hình ảnh mỗi bài viết',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: buildButtonUpload(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButtonUpload() {
    final state = _currentGroupUploadValue.state;
    final isUploading = state == UploadGroupState.uploading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          gradient: isUploading ? null : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isUploading
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isUploading ? null : createPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: isUploading ? Colors.grey[300] : Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isUploading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Đang tải lên...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
              : Text(
                  widget.post != null ? 'Cập nhật' : 'Tạo bài viết',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  void createPost() async {
    
    if (_desCtrl.text.trim().isEmpty &&
        _currentGroupUploadValue.uploadedUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm nội dung hoặc hình ảnh cho bài viết'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final bool res;
      if (widget.post != null) {
        
        res = await _createPostBloc.updatePost(
            widget.post!.id!,
            _desCtrl.text,
            _currentGroupUploadValue.uploadedUrls.isNotEmpty
                ? _currentGroupUploadValue.uploadedUrls
                : (widget.post!.images?.map((img) => img.url ?? '').toList() ??
                    []));
      } else {
        
        res = await _createPostBloc.createPost(
            _desCtrl.text, _currentGroupUploadValue.uploadedUrls);
      }

      if (res) {
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.post != null
                ? 'Không thể cập nhật bài viết. Vui lòng thử lại.'
                : 'Không thể tạo bài viết. Vui lòng thử lại.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

