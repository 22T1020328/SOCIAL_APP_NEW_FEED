import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

import '../../../common/blocs/app_event_bloc.dart';
import '../../../common/mixin/dialog_err_mixin.dart';
import '../../../providers/bloc_provider.dart';
import '../../../services/firebase_service.dart';
import '../../../utils/time_utils.dart';
import '../../../values/app_theme.dart';
import '../../comment/blocs/comments_bloc.dart';
import '../../comment/widgets/list_comment.dart';
import '../../profile/pages/profile_page.dart';
import '../blocs/post_detail_bloc.dart';
import '../models/post.dart';
import '../widgets/action_post.dart';
import '../widgets/grid_image.dart';
import 'create_post_page.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> with DialogErrorMixin {
  Post get post => widget.post;

  PostDetailBloc? get bloc => BlocProvider.of<PostDetailBloc>(context);

  CommentBloc? get cmtBloc => BlocProvider.of<CommentBloc>(context);

  late final TextEditingController txtCtrl;
  late final FocusNode focusNode;
  String? _replyToCommentId;
  String? _replyToUserName;

  @override
  void initState() {
    super.initState();

    bloc!.getPost();

    cmtBloc!.getComments();

    txtCtrl = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    txtCtrl.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: StreamBuilder<Post>(
          stream: bloc!.postsStream,
          initialData: widget.post,
          builder: (context, snapshot) {
            final post = snapshot.data;
            if (post == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          flexibleSpace: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient.scale(0.8),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          iconTheme: const IconThemeData(color: Colors.white),
                          title: const Text(
                            'Chi Tiết Bài Viết',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          snap: true,
                          floating: true,
                          forceElevated: true,
                        ),
                        CupertinoSliverRefreshControl(
                          onRefresh: bloc!.getPost,
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    
                                    GestureDetector(
                                      onTap: () => navigateToProfilePage(
                                          context, post.user),
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage: post.urlUserAvatar !=
                                                    null &&
                                                post.urlUserAvatar!.isNotEmpty
                                            ? NetworkImage(post.urlUserAvatar!)
                                            : null,
                                        child: post.urlUserAvatar == null ||
                                                post.urlUserAvatar!.isEmpty
                                            ? Icon(Icons.person,
                                                color: Colors.grey[600])
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    Expanded(
                                      child: Builder(
                                        builder: (context) {
                                          final verified = post.user?.isVerified ?? false;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      post.displayName,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (verified) ...[
                                                    const SizedBox(width: 4),
                                                    const Icon(
                                                      Icons.verified,
                                                      color: Colors.blue,
                                                      size: 16,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                post.created_at != null
                                                    ? TimeUtils.timeAgo(
                                                        post.created_at!)
                                                    : 'Vừa xong',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      ),
                                    ),
                                    
                                    _buildPopupMenu(post),
                                  ],
                                ),
                              ),

                              
                              if (post.description != null &&
                                  post.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Text(
                                    post.description!,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                ),

                              
                              if (post.hasImages())
                                GridImage(
                                    photos: post.getDisplayPhotos(),
                                    padding: 12),

                              ActionPost(post: post),
                              const Divider(thickness: 1),
                              ListComment(
                                onReply: (commentId, userName) {
                                  setState(() {
                                    _replyToCommentId = commentId;
                                    _replyToUserName = userName;
                                  });
                                  focusNode.requestFocus();
                                },
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        if (_replyToUserName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            color: Colors.grey[100],
                            child: Row(
                              children: [
                                Icon(Icons.reply,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Đang trả lời $_replyToUserName',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close,
                                      size: 18, color: Colors.grey[600]),
                                  onPressed: () {
                                    setState(() {
                                      _replyToCommentId = null;
                                      _replyToUserName = null;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: txtCtrl,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText: _replyToUserName != null
                                        ? 'Viết trả lời...'
                                        : 'Viết bình luận...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  maxLines: null,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _submitComment(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _submitComment,
                                icon: const Icon(Icons.send),
                                color: Color(0xFFE91E63),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  Future<void> _submitComment() async {
    if (txtCtrl.text.trim().isEmpty) return;

    try {
      await cmtBloc!.writeCmt(
        txtCtrl.text.trim(),
        parentCommentId: _replyToCommentId,
      );
      txtCtrl.clear();
      focusNode.unfocus();
      setState(() {
        _replyToCommentId = null;
        _replyToUserName = null;
      });
    } catch (e) {
      showErrorMessage('Lỗi khi viết bình luận');
    }
  }

  void _editPost(Post post) {
    
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CreatePostPage(post: post),
      ),
    );
  }

  Future<void> _deletePost(Post post) async {
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Bài Viết'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && post.id != null) {
      try {
        
        final success = await FirebaseService().deletePost(post.id!);

        if (success && mounted) {
          
          AppEventBloc().emitEvent(BlocEvent(EventName.deletePost, post.id));

          
          Navigator.pop(context);

          
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể xóa bài viết'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showErrorMessage('Lỗi khi xóa bài viết');
        }
      }
    }
  }

  Widget _buildPopupMenu(Post post) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final postOwnerId = post.user?.id;

    
    if (currentUserId == null || currentUserId != postOwnerId) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      onSelected: (value) {
        if (value == 'edit') {
          _editPost(post);
        } else if (value == 'delete') {
          _deletePost(post);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Xóa', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

