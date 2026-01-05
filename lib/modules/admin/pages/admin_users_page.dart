import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../models/user.dart';
import '../../../services/firebase_service.dart';
import '../../../blocs/app_state_bloc.dart';
import '../../../providers/bloc_provider.dart';
import '../../../values/app_theme.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<User> _users = [];
  bool _isLoading = true;

  AppStateBloc? get appStateBloc => BlocProvider.of<AppStateBloc>(context);

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _firebaseService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Không thể tải danh sách người dùng: $e');
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Xác nhận xóa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa người dùng "${user.displayName}"?',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Lưu ý:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Xóa toàn bộ dữ liệu Firestore\n'
                    '• Xóa tất cả bài viết, bình luận\n'
                    '• Tài khoản Auth vẫn tồn tại',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Hủy', style: TextStyle(fontSize: 15)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Xóa', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );

    if (confirmed == true && user.id != null) {
      try {
        final success = await _firebaseService.deleteUser(user.id!);
        if (success) {
          _showSuccess('Đã xóa dữ liệu Firestore của user');
        } else {
          _showError('Không thể xóa người dùng');
        }
        _loadUsers();
      } catch (e) {
        _showError('Lỗi khi xóa: $e');
      }
    }
  }

  Future<void> _toggleVerified(User user) async {
    if (user.id == null) return;

    try {
      await _firebaseService.toggleUserVerified(user.id!, !user.isVerified);
      _showSuccess(user.isVerified ? 'Đã gỡ tích xanh' : 'Đã cấp tích xanh');
      _loadUsers();
    } catch (e) {
      _showError('Không thể cập nhật trạng thái: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await auth.FirebaseAuth.instance.signOut();
      appStateBloc?.changeAppState(AppState.unAuthorized);
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login-page', (route) => false);
      }
    } catch (e) {
      _showError('Không thể đăng xuất: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Quản lý người dùng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              )
            : _users.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có người dùng nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: _loadUsers,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: kToolbarHeight + 40),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final isCurrentUser =
                        user.id == _firebaseService.currentUserId;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: user.imgUrl.isNotEmpty
                                  ? NetworkImage(user.imgUrl)
                                  : null,
                              child: user.imgUrl.isEmpty
                                  ? Text(
                                      user.displayFirstName.isNotEmpty
                                          ? user.displayFirstName[0]
                                                .toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    )
                                  : null,
                            ),
                            if (user.isAdmin)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.displayName.isNotEmpty
                                    ? user.displayName
                                    : user.username ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (user.isVerified)
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20,
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              user.displayUsername,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            if (user.bio != null && user.bio!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                user.bio!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: isCurrentUser
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Bạn',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : PopupMenuButton<String>(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.more_vert, size: 20),
                                ),
                                onSelected: (value) {
                                  if (value == 'verify') {
                                    _toggleVerified(user);
                                  } else if (value == 'delete') {
                                    _deleteUser(user);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'verify',
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            user.isVerified
                                                ? Icons.verified_outlined
                                                : Icons.verified,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          user.isVerified
                                              ? 'Gỡ tích xanh'
                                              : 'Cấp tích xanh',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Xóa người dùng',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
