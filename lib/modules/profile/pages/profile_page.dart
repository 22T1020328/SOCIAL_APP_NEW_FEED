import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:ui';
import '../../../models/user.dart' as app_user;
import '../../../route/route_name.dart';
import '../../../services/firebase_profile_service.dart';
import '../../../modules/posts/models/post.dart';
import '../../../blocs/app_state_bloc.dart';
import '../../../providers/bloc_provider.dart';
import '../../../values/app_theme.dart';
import 'edit_profile_page.dart';
import 'vietqr_payment_page.dart';

class ProfilePage extends StatefulWidget {
  final app_user.User user;

  const ProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = FirebaseProfileService();
  late Future<Map<String, int>> _statsFuture;
  late Future<List<Post>> _postsFuture;
  late Future<bool> _isFollowingFuture;
  late Future<app_user.User?> _userFuture;
  bool _isOwnProfile = false;
  app_user.User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _isOwnProfile =
        firebase_auth.FirebaseAuth.instance.currentUser?.uid == widget.user.id;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _userFuture = _profileService.getUserProfile(widget.user.id!);
      _statsFuture = _profileService.getUserStats(widget.user.id!);
      _postsFuture = _profileService.getUserPosts(widget.user.id!);
      _isFollowingFuture = _isOwnProfile
          ? Future.value(false)
          : _profileService.isFollowing(widget.user.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        child: CustomScrollView(
          slivers: [
          
          SliverAppBar(
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
            title: FutureBuilder<app_user.User?>(
              future: _userFuture,
              initialData: _currentUser,
              builder: (context, snapshot) {
                final user = snapshot.data ?? _currentUser ?? widget.user;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        user.username ?? user.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ],
                  ],
                );
              },
            ),
            pinned: true,
          ),

          
          SliverToBoxAdapter(
            child: FutureBuilder<app_user.User?>(
              future: _userFuture,
              initialData: _currentUser,
              builder: (context, snapshot) {
                final user = snapshot.data ?? _currentUser ?? widget.user;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: user.imgUrl.isNotEmpty
                                ? (kIsWeb
                                    ? NetworkImage(user.imgUrl)
                                    : CachedNetworkImageProvider(user.imgUrl)
                                        as ImageProvider)
                                : null,
                            child: user.imgUrl.isEmpty
                                ? Icon(Icons.person,
                                    size: 40, color: Colors.grey[600])
                                : null,
                          ),
                          const SizedBox(width: 20),

                          
                          Expanded(
                            child: FutureBuilder<Map<String, int>>(
                              future: _statsFuture,
                              builder: (context, snapshot) {
                                final stats = snapshot.data ??
                                    {
                                      'posts': 0,
                                      'followers': 0,
                                      'following': 0
                                    };
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatColumn(
                                        stats['posts']!.toString(), 'Bài viết'),
                                    _buildStatColumn(
                                        stats['followers']!.toString(),
                                        'Người theo dõi'),
                                    _buildStatColumn(
                                        stats['following']!.toString(),
                                        'Đang theo dõi'),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      
                      Row(
                        children: [
                          Text(
                            user.displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (user.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ],
                        ],
                      ),

                      
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          user.bio!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          
          SliverToBoxAdapter(
            child: FutureBuilder<app_user.User?>(
              future: _userFuture,
              initialData: _currentUser,
              builder: (context, snapshot) {
                final user = snapshot.data ?? _currentUser ?? widget.user;
                
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: Column(
                    children: [
                      
                      if (_isOwnProfile && !user.isVerified) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[600]!],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute<bool>(
                                  builder: (context) => VietQRPaymentPage(                                 
                                    userId: widget.user.id!,
                                    userName: user.displayName,
                                  ),
                                ),
                              );

                              
                              if (result == true && mounted) {
                                setState(() {
                                  _userFuture = _profileService
                                      .getUserProfile(widget.user.id!);
                                });
                                _userFuture.then((updatedUser) {
                                  if (mounted && updatedUser != null) {
                                    setState(() {
                                      _currentUser = updatedUser;
                                    });
                                  }
                                });
                              }
                            },
                            icon: const Icon(Icons.verified, size: 20),
                            label: const Text(
                              'Nhận Tích Xanh',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                      
                      
                      if (_isOwnProfile) ...[
                        const SizedBox(height: 15),
                        
                        
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withOpacity(0.1),
                                AppTheme.primaryColor.withOpacity(0.05),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute<bool>(
                                            builder: (context) =>
                                                EditProfilePage(user: widget.user),
                                          ),
                                        );

                                        if (result == true && mounted) {
                                          setState(() {
                                            _userFuture = _profileService
                                                .getUserProfile(widget.user.id!);
                                            _statsFuture =
                                                _profileService.getUserStats(widget.user.id!);
                                            _postsFuture =
                                                _profileService.getUserPosts(widget.user.id!);
                                          });
                                          
                                          _userFuture.then((user) {
                                            if (mounted && user != null) {
                                              setState(() {
                                                _currentUser = user;
                                              });
                                            }
                                          });
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 14,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                              color: Colors.grey[700],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Chỉnh sửa hồ sơ',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red[400]!,
                                      Colors.red[600]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      final shouldLogout = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          title: Row(
                                            children: [
                                              Icon(Icons.logout, color: Colors.red[600]),
                                              const SizedBox(width: 8),
                                              const Text('Đăng xuất'),
                                            ],
                                          ),
                                          content: const Text(
                                            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text(
                                                'Hủy',
                                                style: TextStyle(color: Colors.grey[600]),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red[600],
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text('Đăng xuất'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (shouldLogout == true) {
                                        await firebase_auth.FirebaseAuth.instance.signOut();
                                        if (context.mounted) {
                                          final appStateBloc =
                                              BlocProvider.of<AppStateBloc>(context);
                                          appStateBloc?.changeAppState(AppState.unAuthorized);
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      child: Icon(
                                        Icons.logout_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        FutureBuilder<bool>(
                          future: _isFollowingFuture,
                          builder: (context, snapshot) {
                            final isFollowing = snapshot.data ?? false;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: isFollowing 
                                  ? null
                                  : AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isFollowing ? Colors.grey : AppTheme.primaryColor).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  if (isFollowing) {
                                    await _profileService
                                        .unfollowUser(widget.user.id!);
                                  } else {
                                    await _profileService
                                        .followUser(widget.user.id!);
                                  }
                                  setState(() {
                                    _isFollowingFuture = _profileService
                                        .isFollowing(widget.user.id!);
                                    _statsFuture = _profileService
                                        .getUserStats(widget.user.id!);
                                  });
                                },
                                icon: Icon(
                                  isFollowing
                                      ? Icons.person_remove_outlined
                                      : Icons.person_add_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  isFollowing ? 'Bỏ theo dõi' : 'Theo dõi',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing
                                      ? Colors.grey[200]
                                      : Colors.transparent,
                                  foregroundColor: isFollowing
                                      ? Colors.grey[700]
                                      : Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
  

          
          FutureBuilder<List<Post>>(
            future: _postsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              final posts = snapshot.data ?? [];

              if (posts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isOwnProfile ? 'Chưa có bài viết' : 'Chưa có bài viết',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    final hasImage = post.hasImages();
                    final imageUrl =
                        hasImage ? post.getDisplayPhotos().first.url : null;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteName.postDetailPage,
                          arguments: post,
                        );
                      },
                      child: Container(
                        color: Colors.grey[300],
                        child: hasImage && imageUrl != null
                            ? kIsWeb
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholder(post);
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  )
                                : CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      return _buildPlaceholder(post);
                                    },
                                  )
                            : _buildPlaceholder(post),
                      ),
                    );
                  },
                  childCount: posts.length,
                ),
              );
            },
          ),
        ],
      ),
      )
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(Post post) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article,
              size: 32,
              color: Colors.grey[600],
            ),
            if (post.description != null && post.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  post.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

        
    
  }
}

void navigateToProfilePage(BuildContext context, app_user.User? user) {
  if (user != null) {
    Navigator.pushNamed(context, RouteName.profilePage, arguments: user);
  }
}

