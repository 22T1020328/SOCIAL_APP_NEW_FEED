import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'auto_hide_keyboard.dart';

class LoadingHideKeyboard extends StatelessWidget {

  final Widget child;
  final bool isLoading;

  const LoadingHideKeyboard({Key? key, required this.isLoading, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AutoHideKeyboard(child: child),
        if (isLoading)
          Container(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            child: const Center(
              child: CupertinoActivityIndicator(radius: 16),
            ),
          ),
      ],
    );
  }
}

