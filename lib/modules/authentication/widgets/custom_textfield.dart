import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail/modules/authentication/bloc/my_form_bloc.dart';
import 'package:socail/values/app_colors.dart';
import 'package:socail/values/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final FocusNode focusNode;
  final double? radius;
  final double? widthBorder;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool? obscureText;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final String? initialValue;
  final TextInputType? keyboardType;
   CustomTextField({Key? key,this.radius,this.widthBorder,
     this.hintText,required this.focusNode,this.helperText,this.errorText,this.obscureText,
   this.textInputType,this.textInputAction,this.initialValue,this.keyboardType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyFormBloc,MyFormState>(
      builder: (context,state){
      return TextFormField(
        initialValue: state.email.value,
        decoration: InputDecoration(
          helperText: helperText,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(25.7),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(25.7),
            ),
          filled: true,
          fillColor: AppColors.likeColor.withOpacity(0.2),
          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(radius ?? 25.7),
          ),
          hintText: hintText,
          hintStyle: AppStyles.h2.copyWith(color: Colors.white)
        ),
        focusNode: focusNode,
        obscureText: true,
        textInputAction: textInputAction,


      );
      }
    );
  }
}
class EmailInput extends StatelessWidget {
  const EmailInput({super.key, required this.focusNode});

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyFormBloc, MyFormState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: state.email.value,
          focusNode: focusNode,
          decoration: InputDecoration(
            icon: const Icon(Icons.email),
            labelText: 'Email',
            helperText: 'A complete, valid email e.g. joe@gmail.com',
            errorText: state.email.invalid
                ? 'Please ensure the email entered is valid'
                : null,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            context.read<MyFormBloc>().add(EmailChanged(email: value));
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}

