import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../values/app_colors.dart';

class CircleAvatarBorder extends StatelessWidget {
  final String? avatarUrl;
  final double size;

  const CircleAvatarBorder({
    Key? key,
    this.avatarUrl,
    this.size = 32
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        
        
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: (avatarUrl != null && avatarUrl!.isNotEmpty)
            ? kIsWeb
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, obj, stack) {
                      return _buildDefaultAvatar();
                    },
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                          ),
                        ),
                      );
                    },
                  )
                : CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (ctx, str, obj) {
                      return _buildDefaultAvatar();
                    },
                    placeholder: (ctx, str) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                        ),
                      ),
                    ),
                  )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.blueColor,
      ),
      child: Icon(
        Icons.person,
        size: size - 10,
        color: AppColors.likeColor,
      ),
    );
  }
}

