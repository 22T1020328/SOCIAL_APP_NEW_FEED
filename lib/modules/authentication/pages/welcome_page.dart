import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../blocs/app_state_bloc.dart';
import '../../../common/widgets/stateless/error_popup.dart';
import '../../../providers/bloc_provider.dart';
import '../bloc/authentication_bloc.dart';
import '../enum/login_state.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  AppStateBloc? get appStateBloc => BlocProvider.of<AppStateBloc>(context);
  AuthenticationBloc? get authenBloc =>
      BlocProvider.of<AuthenticationBloc>(context);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFD1D1D), 
                    Color(0xFFE1306C), 
                    Color(0xFFC13584), 
                    Color(0xFF833AB4), 
                  ]
              )
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFD1D1D),
                            Color(0xFFE1306C),
                            Color(0xFF833AB4),
                          ],
                        ).createShader(bounds),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    
                    const Text(
                      'Kết nối với bạn bè',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Chia sẻ khoảnh khắc và kết nối với mọi người xung quanh bạn',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 60),
                    
                    
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login-page');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFE1306C),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFD1D1D),
                              Color(0xFFE1306C),
                              Color(0xFF833AB4),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'Đăng Nhập',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/sign-up-page');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Tạo Tài Khoản',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    
                    const Text(
                      'Hoặc đăng nhập với',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: Icons.g_mobiledata,
                          onTap: _signInWithGmail,
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          icon: Icons.facebook,
                          onTap: () {},
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          icon: Icons.apple,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _signInWithGmail() async {
    
    try {
      final loginState = await authenBloc!.loginWithGmail();
      
      
      switch (loginState) {
        case LoginState.success:
          _changeAppState();
          return; 
        case LoginState.newUser:
          
          _changeAppState();
          return; 
        default:
          _showDialog('Đăng nhập không thành công. Vui lòng thử lại.');
          return;
      }
    } on PlatformException catch (e) {
      
      _handleErrorPlatformException(e);
    } catch (e) {
      _showDialog('Đã xảy ra lỗi! Vui lòng thử lại.');
    }
  }

  void _changeAppState() {
    appStateBloc!.changeAppState(AppState.authorized);
  }

  void _handleErrorPlatformException(PlatformException e) {
    if (e.code != 'ERROR_ABORTED_BY_USER') {
      _showDialog(e.message ?? '');
    }
  }

  void _showDialog(String content) {
    showDialog<void>(
      context: context,
      builder: (ctx) => ErrorPopup(content: content),
    );
  }
}

