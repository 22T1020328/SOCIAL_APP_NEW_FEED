import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socail/common/widgets/stateless/modern_app_bar.dart';
import 'package:socail/modules/posts/widgets/post_item.dart';
import 'package:socail/values/app_theme.dart';
import '../../../blocs/app_state_bloc.dart';
import '../../../providers/bloc_provider.dart';
import '../../../route/route_name.dart';
import '../../../services/firebase_service.dart';
import '../../posts/blocs/list_posts_rxdart_bloc.dart';
import '../../posts/models/post.dart';
import '../../search/pages/search_page.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _firebaseService = FirebaseService();
  ListPostsRxDartBloc? _postsBloc;
  String? _userAvatarUrl;

  AppStateBloc? get appStateBloc => BlocProvider.of<AppStateBloc>(context);
  final user = FirebaseAuth.instance.currentUser;
  
  @override
  void initState(){
    super.initState();
    _postsBloc = ListPostsRxDartBloc();
    _postsBloc?.getPosts(); 
    _loadUserAvatar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload avatar mỗi khi dependencies thay đổi (bao gồm khi F5)
    _loadUserAvatar();
  }

  Future<void> _loadUserAvatar() async {
    if (user != null) {
      final userProfile = await _firebaseService.getUser(user!.uid);
      if (mounted && userProfile != null) {
        setState(() {
          _userAvatarUrl = userProfile.imgUrl;
        });
      }
    }
  }

  @override
  void dispose() {
    _postsBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Thêm timestamp để force reload avatar khi cập nhật
    final avatarUrlWithTimestamp = _userAvatarUrl != null && _userAvatarUrl!.isNotEmpty
        ? '$_userAvatarUrl?t=${DateTime.now().millisecondsSinceEpoch}'
        : _userAvatarUrl;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: ModernAppBar(
        title: 'Trang chủ',
        avatarUrl: avatarUrlWithTimestamp,
        onProfileTap: () async {
          final currentUser = user;
          if (currentUser != null) {
            final userProfile = await _firebaseService.getUser(currentUser.uid);
            if (userProfile != null && mounted) {
              // Navigate đến profile và đợi kết quả quay lại
              await Navigator.pushNamed(
                context,
                RouteName.profilePage,
                arguments: userProfile,
              );
              
              // Khi quay lại từ profile, reload avatar
              if (mounted) {
                await _loadUserAvatar();
              }
            }
          }
        },
        onSearchTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (context) => const SearchPage()),
          );
        },
        onNotificationTap: () {
          Navigator.pushNamed(context, RouteName.notificationsPage);
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'create',
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 32),
          onPressed: () {
            Navigator.pushNamed(context, RouteName.createPostPage);
          },
        ),
      ),
      body: Column(
        children: [
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          const SizedBox(
            height: 19,
          ),

          Expanded(
            child: _postsBloc == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await _postsBloc!.getPosts();
                    },
                    child: StreamBuilder<List<Post>?>(
                    stream: _postsBloc!.postsStream,
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
                          Text(
                            'Lỗi khi tải bài viết',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có bài viết nào',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final posts = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (_, int index) {
                      final item = posts[index];
                      return PostItem(
                        post: item,
                      );
                    },
                    itemCount: posts.length,
                  );
                }),
                  ),
          ),
        ],
      ),
    );
  }
}

