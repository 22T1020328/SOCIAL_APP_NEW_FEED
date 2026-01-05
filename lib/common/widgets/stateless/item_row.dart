import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'circle_avatar_border.dart';

class ItemRow extends StatelessWidget {
  final String? avatarUrl;
  final double sizeAvatar;
  final String? title;
  final String? subtitle;
  final bool isVerified;

  final Widget? avatarWidget;
  final Widget? bodyWidget;
  final Widget? rightWidget;

  final VoidCallback? onTap;
  final String? postOwnerId;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ItemRow({
    Key? key,
    this.avatarUrl,
    this.sizeAvatar = 36,
    this.title,
    this.subtitle,
    this.isVerified = false,
    this.avatarWidget,
    this.bodyWidget,
    this.rightWidget,
    this.onTap,
    this.postOwnerId,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        
        buildAvatar(context),
        const SizedBox(width: 12),
        
        
        Expanded(
          child: bodyWidget ?? buildBodyWidget(context),
        ),
        
        
        rightWidget ?? _buildPopupMenu(context),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = postOwnerId != null && currentUserId == postOwnerId;

    
    if (!isOwner || (onDelete == null && onEdit == null)) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (String value) {
        if (value == 'edit' && onEdit != null) {
          onEdit!();
        } else if (value == 'delete' && onDelete != null) {
          onDelete!();
        }
      },
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> items = [];

        if (onEdit != null) {
          items.add(
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.black87),
                  SizedBox(width: 12),
                  Text('Chỉnh sửa', style: TextStyle(fontSize: 14))
                ],
              ),
            ),
          );
        }

        if (onDelete != null) {
          items.add(
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Xóa', style: TextStyle(color: Colors.red, fontSize: 14))
                ],
              ),
            ),
          );
        }

        return items;
      },
    );
  }

  Widget buildBodyWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildTitle(context),
        buildSubTitle(context),
      ],
    );
  }

  Widget buildAvatar(BuildContext context) {
    Widget? built = avatarWidget;

    if (built == null && avatarUrl != null) {
      built = CircleAvatarBorder(avatarUrl: avatarUrl, size: sizeAvatar);
    }

    if (built != null && onTap != null) {
      built = GestureDetector(child: built, onTap: onTap);
    }

    return built ?? const SizedBox.shrink();
  }

  Widget buildTitle(BuildContext context) {
    if (title == null) return const SizedBox.shrink();

    Widget nameWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        if (isVerified) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.verified,
            color: Colors.blue,
            size: 16,
          ),
        ],
      ],
    );

    if (onTap != null) {
      nameWidget = GestureDetector(child: nameWidget, onTap: onTap);
    }

    return nameWidget;
  }

  Widget buildSubTitle(BuildContext context) {
    if (subtitle == null) {
      return const SizedBox();
    }
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Text(
        subtitle!,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

