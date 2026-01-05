import 'package:flutter/material.dart';
import 'package:socail/values/app_colors.dart';
import 'package:socail/values/app_styles.dart';
import 'package:socail/widgets/app_buttons.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            opacity: 0.3,
            fit: BoxFit.cover,
            image: AssetImage('assets/images/fashion.jpg')
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [GradientAppColor.bg_copy2,GradientAppColor.bg_copy]
          )
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 105.0,),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 30),
                child: Text('Welcome back',
                style: AppStyles.h4,
                ),
              ),
              const SizedBox(height: 12,),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 30),
                child: Text('Login to your account',
                  style: AppStyles.h2,
                ),
              ),
              const SizedBox(height: 58.0,),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                height: 44,
                child: TextField(
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.greenAccent, width: 2.0),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                    ),
                    labelStyle:const TextStyle(color: AppColors.likeColor),
                    labelText: 'Email',
                    filled: true,
                    fillColor: AppColors.likeColor2,

                  )
                ),
              ),
              const SizedBox(height: 10.0,),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                height: 44,
                child: TextField(
                    decoration: InputDecoration(
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent, width: 2.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                      ),
                      labelStyle:const TextStyle(color: AppColors.likeColor),
                      labelText: 'Password',
                      filled: true,
                      fillColor: AppColors.likeColor2,
                      
                      
                      
                    )
                ),
              ),
              const SizedBox(height: 40.0,),
              AppButton(
                  onPressed: (){},
                  nameButton: 'Login',
                  colorText: AppColors.likeColor,
                  gradient: const LinearGradient(
                    colors: [GradientAppColor.pinkColor1,GradientAppColor.pinkColor2]
                  ),
              ),
              const SizedBox(height: 53,),
              Text('Forgot your password?',
              style: AppStyles.h2,)
            ],
          ),
        )
      ),
    );
  }
}

