import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppTextField({
    Key? key,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? effectivePrefixIcon = prefixIcon != null
        ? Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: prefixIcon,
          )
        : null;

    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: effectivePrefixIcon,
        prefixIconConstraints: effectivePrefixIcon != null
            ? const BoxConstraints(minWidth: 0, minHeight: 0)
            : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}