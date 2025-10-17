import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';

import 'package:tirtha_app/presentation/widgets/app_text_field.dart';

class PasswordTextField extends StatefulWidget {
  final String hintText;
  final Widget? prefixIcon;
  final TextEditingController controller;

  const PasswordTextField({Key? key, required this.hintText, this.prefixIcon, required this.controller})
    : super(key: key);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      obscureText: !_isPasswordVisible,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Icon(Icons.lock, color: AppColors.primary),
      ),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.primary,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }
}
