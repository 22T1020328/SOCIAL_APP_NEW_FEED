import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socail/modules/posts/blocs/post_detail_bloc.dart';
import 'package:socail/modules/posts/models/post.dart';
import 'package:socail/modules/posts/pages/post_detail_page.dart';
import 'package:socail/pages/sign_up_page.dart';
import 'package:socail/providers/bloc_provider.dart';
import 'package:socail/route/route_name.dart';
import '../modules/authentication/pages/welcome_page.dart';
import '../modules/authentication/pages/simple_login_page.dart';
import '../modules/admin/pages/admin_users_page.dart';
import '../modules/comment/blocs/comments_bloc.dart';
import '../modules/posts/pages/create_post_page.dart';
import '../modules/notifications/pages/notifications_page.dart';
import '../modules/profile/pages/profile_page.dart';
import '../models/user.dart' as app_user;
import '../pages/main_page.dart';

class Routes {
  static Route<dynamic> authorizedRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(settings, const MainPage());
      case RouteName.createPostPage:
        return _buildRouteDialog(settings, const CreatePostPage());
      case RouteName.postDetailPage:
        final post = settings.arguments;
        if (post is Post) {
          return _buildRoute(
            settings,
            BlocProvider(
              bloc: PostDetailBloc(post.id!),
              child: BlocProvider(
                bloc: CommentBloc(post.id!),
                child: PostDetailPage(post: post),
              ),
            ),
          );
        }
        return _errorRoute();
      case RouteName.notificationsPage:
        return _buildRoute(settings, const NotificationsPage());
      case RouteName.profilePage:
        final user = settings.arguments;
        if (user is app_user.User) {
          return _buildRoute(settings, ProfilePage(user: user));
        }
        return _errorRoute();
      case RouteName.adminUsersPage:
        return _buildRoute(settings, const AdminUsersPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> unAuthorizedRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(settings, const WelcomePage());
      case RouteName.loginPage:
        return _buildRoute(settings, const SimpleLoginPage());
      case RouteName.signUpPage:
        return _buildRoute(settings, const SignUpPage());
      case RouteName.adminUsersPage:
        return _buildRoute(settings, const AdminUsersPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Coming soon')),
          body: const Center(child: Text('Page not found')),
        );
      },
    );
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    RouteSettings settings,
    Widget builder,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => builder,
    );
  }

  static MaterialPageRoute<dynamic> _buildRouteDialog(
    RouteSettings settings,
    Widget builder,
  ) {
    return MaterialPageRoute(
      settings: settings,
      fullscreenDialog: true,
      builder: (BuildContext context) => builder,
    );
  }
}
