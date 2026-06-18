import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/widgets/custom_text_field.dart';

class PasswordFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final ValueChanged<String> onChanged;

  const PasswordFieldWidget({
    super.key,
    required this.controller,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: 'Amira297',
      textAlign: TextAlign.right,
      obscureText: obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.primary,
          size: 20.r,
        ),
        onPressed: onToggleObscure,
      ),
      onChanged: onChanged,
    );
  }
}
