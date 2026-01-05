import 'package:flutter/material.dart';

class AutoHideKeyboard extends StatelessWidget {
  final Widget child;

  const AutoHideKeyboard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

