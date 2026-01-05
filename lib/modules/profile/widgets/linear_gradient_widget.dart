import 'package:flutter/material.dart';

class LinearGradientWidget extends StatelessWidget {
  final Widget child;

  const LinearGradientWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black,
            Colors.black.withOpacity(0),
          ],
        ),
      ),
      child: child,
    );
  }
}

