import 'package:flutter/material.dart';
import '../../../values/app_theme.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final String? avatarUrl;
  final int notificationCount;

  const ModernAppBar({
    Key? key,
    required this.title,
    this.onProfileTap,
    this.onSearchTap,
    this.onNotificationTap,
    this.avatarUrl,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    key: ValueKey(avatarUrl), // Force rebuild khi avatarUrl thay đổi
                    backgroundColor: Colors.white,
                    backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null || avatarUrl!.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 24,
                            color: AppTheme.primaryColor,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              
              if (onSearchTap != null)
                _buildIconButton(
                  icon: Icons.search_rounded,
                  onTap: onSearchTap!,
                ),
              
              const SizedBox(width: 8),
              
              
              if (onNotificationTap != null)
                Stack(
                  children: [
                    _buildIconButton(
                      icon: Icons.notifications_rounded,
                      onTap: onNotificationTap!,
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            notificationCount > 9 ? '9+' : '$notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

