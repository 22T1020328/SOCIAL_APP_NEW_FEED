import 'package:flutter/material.dart';
import 'package:socail/modules/posts/models/post.dart';
import 'package:socail/modules/posts/widgets/grid_image.dart';


import '../../../common/blocs/app_event_bloc.dart';
import '../../../common/widgets/stateless/item_row.dart';
import '../../../route/route_name.dart';
import '../../../services/firebase_service.dart';
import '../../../utils/time_utils.dart';
import '../../profile/pages/profile_page.dart';
import '../pages/create_post_page.dart';
import 'action_post.dart';

class PostItem extends StatelessWidget {
  final Post post;
  const PostItem({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: GestureDetector(
        onTap: () {
          
          Navigator.pushNamed(
            context,
            RouteName.postDetailPage,
            arguments: post,
          );
        },
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Builder(
                    builder: (context) {
                      final verified = post.user?.isVerified ?? false;
                      return ItemRow(
                        avatarUrl: post.urlUserAvatar,
                        sizeAvatar: 40,
                        title: post.displayName,
                        subtitle: post.created_at != null
                            ? TimeUtils.timeAgo(post.created_at!)
                            : 'Vừa xong',
                        isVerified: verified,
                        onTap: () {
                          
                          navigateToProfilePage(context, post.user);
                        },
                        postOwnerId: post.user?.id,
                        onEdit: () {
                          
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => CreatePostPage(post: post),
                            ),
                          );
                        },
                        onDelete: () async {
                          
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xóa bài viết'),
                              content: const Text(
                                  'Bạn có chắc chắn muốn xóa bài viết này không?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Xóa',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && post.id != null) {
                            
                            final success =
                                await FirebaseService().deletePost(post.id!);

                            if (success && context.mounted) {
                              
                              AppEventBloc().emitEvent(
                                  BlocEvent(EventName.deletePost, post.id));

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã xóa bài viết thành công'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Không thể xóa bài viết'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      );
                    }
                  ),
                ),

                
                if (post.description != null && post.description!.isNotEmpty)
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Text(
                      post.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 4),

                
                if (post.hasImages())
                  GridImage(photos: post.getDisplayPhotos()),

                if (post.hasImages())
                  const SizedBox(
                    height: 8.0,
                  ),

                
                ActionPost(post: post),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

