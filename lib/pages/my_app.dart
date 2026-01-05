import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import '../blocs/app_state_bloc.dart';
import '../modules/authentication/bloc/authentication_bloc.dart';
import '../modules/authentication/wrapper/service/app_auth_service.dart';
import '../providers/bloc_provider.dart';
import '../route/routes.dart';
class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appStateBloc = AppStateBloc();
  late AuthenticationBloc _authenticationBloc;
  static final GlobalKey<State> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _authenticationBloc = AuthenticationBloc(AppAuthService());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: appStateBloc,
      child: StreamBuilder<AppState>(
          stream: appStateBloc.appState,
          initialData: appStateBloc.initState,
          builder: (context, snapshot) {
            if (snapshot.data == AppState.loading) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Container(
                  color: Colors.white,
                ),
              );
            }
            if (snapshot.data == AppState.unAuthorized) {
              return BlocProvider(
                bloc: _authenticationBloc,
                child: OverlaySupport.global(
                  child: MaterialApp(
                    key: const ValueKey('UnAuthorized'),
                    themeMode: ThemeMode.light,
                    builder: _builder,
                    
                    onGenerateRoute: Routes.unAuthorizedRoute,
                    debugShowCheckedModeBanner: false,
                  ),
                ),
              );
            }

            return OverlaySupport.global(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                initialRoute: '/',
                onGenerateRoute: Routes.authorizedRoute,
                theme: ThemeData(
                  primaryColor: const Color(0xff4E586E),
                ),
                key: key,
                builder: _builder,
                navigatorKey: MyApp.navigatorKey,
              ),
            );
          }),
    );
  }

  Widget _builder(BuildContext context, Widget? child) {
    final data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(textScaleFactor: 1),
      child: child!,
    );
  }
}

