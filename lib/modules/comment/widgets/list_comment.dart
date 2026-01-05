import 'package:flutter/material.dart';
import 'package:socail/modules/comment/models/comment.dart';
import '../../../common/widgets/stateless/activity_indicator.dart';
import '../../../providers/bloc_provider.dart';
import '../blocs/comments_bloc.dart';
import 'comment_item_bubble.dart';

class ListComment extends StatefulWidget {
  final void Function(String commentId, String userName)? onReply;

  const ListComment({Key? key, this.onReply}) : super(key: key);

  @override
  _ListCommentState createState() => _ListCommentState();
}

class _ListCommentState extends State<ListComment> {
  CommentBloc? get commentBloc => BlocProvider.of<CommentBloc>(context);

  List<Comment> _organizeComments(List<Comment> comments) {

    
    final parentComments = <Comment>[];
    final repliesMap = <String, List<Comment>>{};

    for (var comment in comments) {

      if (comment.parentCommentId == null || comment.parentCommentId!.isEmpty) {
        parentComments.add(comment);
      } else {
        if (!repliesMap.containsKey(comment.parentCommentId)) {
          repliesMap[comment.parentCommentId!] = [];
        }
        repliesMap[comment.parentCommentId]!.add(comment);
      }
    }

    
    for (var parent in parentComments) {
      if (parent.id != null && repliesMap.containsKey(parent.id)) {
        parent.replies = repliesMap[parent.id];
      }
    }

    return parentComments;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Comment>?>(
      stream: commentBloc!.listCmtStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: ActivityIndicator(),
          );
        }

        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(top: 12),
              child: const Center(
                child: Text('Không có bình luận nào'),
              ),
            );
          }

          final organizedComments = _organizeComments(snapshot.data!);

          return ListView.builder(
            
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              final comment = organizedComments[index];

              return Container(
                key: ValueKey(comment.id),
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    
                    CommentItemBubble(
                      cmt: comment,
                      isReply: false,
                      onLike: (isLiked) {
                        commentBloc!.react(comment.id!, isLiked ? 1 : 0);
                      },
                      onReply: () {
                        if (widget.onReply != null && comment.id != null) {
                          widget.onReply!(comment.id!, comment.displayName);
                        }
                      },
                    ),

                    
                    if (comment.replies != null && comment.replies!.isNotEmpty)
                      ...comment.replies!.map((reply) => Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: CommentItemBubble(
                              cmt: reply,
                              isReply: true,
                              onLike: (isLiked) {
                                commentBloc!.react(reply.id!, isLiked ? 1 : 0);
                              },
                              onReply: () {
                                if (widget.onReply != null &&
                                    comment.id != null) {
                                  
                                  widget.onReply!(
                                      comment.id!, comment.displayName);
                                }
                              },
                            ),
                          )),
                  ],
                ),
              );
            },
            itemCount: organizedComments.length,
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Đã xảy ra lỗi'),
          );
        }
        return const ActivityIndicator();
      },
    );
  }
}

