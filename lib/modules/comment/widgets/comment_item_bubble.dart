import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:socail/modules/comment/models/comment.dart';
import '../../../utils/time_utils.dart';
import '../../../route/route_name.dart';

class CommentItemBubble extends StatefulWidget {
  final Comment cmt;
  final void Function(bool) onLike;
  final VoidCallback? onReply;
  final bool isReply;

  const CommentItemBubble({
    Key? key,
    required this.cmt,
    required this.onLike,
    this.onReply,
    this.isReply = false,
  }) : super(key: key);

  @override
  State<CommentItemBubble> createState() => _CommentItemBubbleState();
}

class _CommentItemBubbleState extends State<CommentItemBubble> {
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    
    isLiked = widget.cmt.liked ?? false;
  }

  @override
  void didUpdateWidget(CommentItemBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final oldLiked = oldWidget.cmt.liked ?? false;
    final newLiked = widget.cmt.liked ?? false;
    
    if (oldLiked != newLiked) {
      setState(() {
        isLiked = newLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final likeCount = widget.cmt.likeCounts ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              GestureDetector(
                onTap: () {
                  if (widget.cmt.user != null) {
                    Navigator.pushNamed(
                      context,
                      RouteName.profilePage,
                      arguments: widget.cmt.user,
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: widget.cmt.urlUserAvatar != null &&
                          widget.cmt.urlUserAvatar!.isNotEmpty
                      ? NetworkImage(widget.cmt.urlUserAvatar!)
                      : null,
                  child: widget.cmt.urlUserAvatar == null ||
                          widget.cmt.urlUserAvatar!.isEmpty
                      ? Icon(Icons.person, size: 16, color: Colors.grey[600])
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          GestureDetector(
                            onTap: () {
                              if (widget.cmt.user != null) {
                                Navigator.pushNamed(
                                  context,
                                  RouteName.profilePage,
                                  arguments: widget.cmt.user,
                                );
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.cmt.displayName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.cmt.user?.isVerified ?? false) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 14,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.cmt.content ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Row(
                        children: [
                          Text(
                            widget.cmt.createdAt != null
                                ? TimeUtils.timeAgo(widget.cmt.createdAt!)
                                : 'Just now',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),

                          
                          if (likeCount > 0)
                            Text(
                              '$likeCount ${likeCount == 1 ? 'lượt thích' : 'lượt thích'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          if (likeCount > 0) const SizedBox(width: 16),

                          
                          InkWell(
                            onTap: widget.onReply,
                            child: Text(
                              'Trả lời',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                      widget.onLike(isLiked);
                    },
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

