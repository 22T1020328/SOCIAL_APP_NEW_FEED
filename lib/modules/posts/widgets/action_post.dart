import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socail/modules/posts/widgets/text_count_number.dart';
import 'package:socail/modules/posts/widgets/toggle.dart';

import '../../../common/blocs/app_event_bloc.dart';
import '../../../utils/model_type.dart';
import '../blocs/like_bloc.dart';
import '../models/post.dart';
import '../repos/firebase_like_repo.dart';
import 'icon_post_comment.dart';


class ActionPost extends StatefulWidget {
  final Post post;

  const ActionPost({Key? key, required this.post}) : super(key: key);

  @override
  _ActionPostState createState() => _ActionPostState();
}

class _ActionPostState extends State<ActionPost> {
  Post get post => widget.post;
  int likeCount = 0;
  bool isLiked = false;

  int get commentCount => post.commentCounts ?? 0;

  final likeBloc = LikeBloc(FirebaseLikeRepo(ModelType.post));

  @override
  void initState() {
    super.initState();

    likeCount = post.likeCounts ?? 0;
    isLiked = post.liked ?? false;
  }

  @override
  void didUpdateWidget(ActionPost oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldLiked = oldWidget.post.liked ?? false;
    final newLiked = widget.post.liked ?? false;
    
    if (oldLiked != newLiked || oldWidget.post.likeCounts != widget.post.likeCounts) {
      setState(() {
        likeCount = widget.post.likeCounts ?? 0;
        isLiked = widget.post.liked ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 0, left: 4),
                  child: Toggle(
                    isActivated: isLiked,
                    deActivatedChild: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(8),
                      child: const Icon(CupertinoIcons.heart),
                    ),
                    activatedChild: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        CupertinoIcons.heart_solid,
                        color: Colors.red,
                      ),
                    ),
                    onTrigger: _handleLikePost,
                    onTap: (isOn) {
                      setState(() {
                        likeCount = isOn ? likeCount + 1 : likeCount - 1;
                        isLiked = isOn;
                      });
                    },
                  ),
                ),
                const IconPostComment(),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextCountNumber(
                number: likeCount,
                subText: 'lượt thích',
              ),
              TextCountNumber(
                number: post.commentCounts!,
                subText: 'bình luận',
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> _handleLikePost(bool isLiked) async {
    !isLiked ? await likeBloc.unlike(post.id!) : await likeBloc.like(post.id!);

    final event =
        !isLiked ? EventName.unLikePostDetail : EventName.likePostDetail;

    AppEventBloc().emitEvent(BlocEvent(event, post.id));
  }
}

