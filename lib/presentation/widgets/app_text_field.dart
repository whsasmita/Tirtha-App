import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  // 💡 Tambahkan parameter keyboardType
  final TextInputType keyboardType;

  const AppTextField({
    Key? key,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    required this.controller,
    // 💡 Tetapkan nilai default ke TextInputType.text
    this.keyboardType = TextInputType.text, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      controller: controller,
      // 💡 Teruskan keyboardType ke widget TextField internal
      keyboardType: keyboardType, 
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
