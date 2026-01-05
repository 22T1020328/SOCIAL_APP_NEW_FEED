import 'package:flutter/material.dart';

import '../values/app_styles.dart';

class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String nameButton;
  final Color? colorButton;
  final Color colorText;
  final Gradient? gradient;

  const AppButton(
      {Key? key,
      required this.onPressed,
      required this.nameButton,
       this.colorButton,
      required this.colorText,
      this.gradient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22.0)
        ),
        width: double.infinity,
        height: 44.0,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0))),
          child: Text(
            nameButton,
            style: AppStyles.h3.copyWith(color: colorText),
          ),
        ),
      ),
    );
  }
}

