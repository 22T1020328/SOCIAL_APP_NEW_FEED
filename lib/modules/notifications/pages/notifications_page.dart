import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/notification.dart';
import '../../../services/firebase_notification_service.dart';
import '../../../services/firebase_service.dart';
import '../../../common/widgets/notification_item.dart';
import '../../../route/route_name.dart';
import '../../../values/app_theme.dart';
import '../../posts/models/post.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationService = FirebaseNotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX:100, sigmaY: 100),
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
          'Thông báo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          
          StreamBuilder<List<NotificationModel>>(
            stream: _notificationService.getNotificationsStream(),
            builder: (context, snapshot) {
              final hasUnread = snapshot.hasData &&
                  snapshot.data!.any((n) => !n.isRead);

              if (!hasUnread) return const SizedBox.shrink();

              return TextButton(
                onPressed: () async {
                  await _notificationService.markAllAsRead();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã đánh dấu tất cả là đã đọc'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Đánh dấu đã đọc',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: StreamBuilder<List<NotificationModel>>(
        stream: _notificationService.getNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lỗi khi tải thông báo',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có thông báo nào',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Stream tự động refresh, chỉ cần đợi một chút
              await Future<void>.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationItem(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification),
                  onDelete: () => _handleNotificationDelete(notification.id),
                );
              },
            ),
          );
        },
      ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) async {
    
    if (!notification.isRead) {
      await _notificationService.markAsRead(notification.id);
    }

    
    if (!mounted) return;

    if (notification.type == 'follow') {
      
      
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${notification.actorName} đã theo dõi bạn'),
        ),
      );
    } else if (notification.postId != null) {
      
      try {
        
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final result = await FirebaseService().getPost(notification.postId!);
        
        
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (result['code'] == 200 && result['data'] != null) {
          final post = Post.fromJson(result['data'] as Map<String, dynamic>);
          
          if (mounted) {
            Navigator.pushNamed(
              context,
              RouteName.postDetailPage,
              arguments: post,
            );
          }
        } else {
          throw Exception('Không thể tải bài viết');
        }
      } catch (e) {
        
        if (mounted) {
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: Không thể mở bài viết'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleNotificationDelete(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa thông báo'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

