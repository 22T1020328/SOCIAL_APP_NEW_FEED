import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../modules/dashboard/pages/dashboard_page.dart';
import '../modules/notifications/pages/notifications_page.dart';
import '../modules/profile/pages/profile_page.dart';
import '../services/firebase_service.dart';
import '../models/user.dart' as app_user;
import '../route/route_name.dart';
import '../blocs/app_state_bloc.dart';
import '../providers/bloc_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final _firebaseService = FirebaseService();
  app_user.User? _currentUserProfile;
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProfile();
  }

  Future<void> _checkAuthAndLoadProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final appStateBloc = BlocProvider.of<AppStateBloc>(context);
          appStateBloc?.changeAppState(AppState.unAuthorized);
        }
      });
      return;
    }
    
    
    await _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoadingProfile = true);
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      try {
        final userProfile = await _firebaseService.getUser(currentUser.uid);
        if (mounted) {
          setState(() {
            _currentUserProfile = userProfile;
            _isLoadingProfile = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingProfile = false);
        }
      }
    } else {
      setState(() => _isLoadingProfile = false);
    }
  }

  List<Widget> get _pages {
    return [
      const DashboardPage(),
      const NotificationsPage(),
      if (_currentUserProfile != null)
        ProfilePage(user: _currentUserProfile!)
      else if (_isLoadingProfile)
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải hồ sơ...'),
            ],
          ),
        )
      else
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải hồ sơ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Vui lòng thử đăng nhập lại'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkAuthAndLoadProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(RouteName.welcomePage);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFE91E63),
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}

