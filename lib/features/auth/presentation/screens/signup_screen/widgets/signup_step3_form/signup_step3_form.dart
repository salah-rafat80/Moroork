import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/app_sizes.dart';
import 'widgets/form_title_widget.dart';
import 'widgets/field_label_widget.dart';
import 'widgets/password_field_widget.dart';
import 'widgets/password_requirements_list_widget.dart';
import 'widgets/navigation_buttons_widget.dart';

class SignupStep3Form extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleConfirmObscure;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final bool passwordsMatch;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialChar;
  final bool notSameAsUsername;
  final VoidCallback onNextPressed;
  final VoidCallback onPreviousPressed;
  final bool isValid;
  final bool isLoading;

  const SignupStep3Form({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onToggleObscure,
    required this.onToggleConfirmObscure,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.passwordsMatch,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecialChar,
    required this.notSameAsUsername,
    required this.onNextPressed,
    required this.onPreviousPressed,
    required this.isValid,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = context.buttonHeightS;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const FormTitleWidget(title: 'أنشئ كلمة المرور الخاصة بك'),
            SizedBox(height: 20.h),
            const FieldLabelWidget(label: 'أنشئ كلمة المرور'),
            SizedBox(height: 5.h),
            PasswordFieldWidget(
              controller: passwordController,
              obscurePassword: obscurePassword,
              onToggleObscure: onToggleObscure,
              onChanged: onPasswordChanged,
            ),
            SizedBox(height: 16.h),
            const FieldLabelWidget(label: 'تأكيد كلمة المرور'),
            SizedBox(height: 5.h),
            PasswordFieldWidget(
              controller: confirmPasswordController,
              obscurePassword: obscureConfirmPassword,
              onToggleObscure: onToggleConfirmObscure,
              onChanged: onConfirmPasswordChanged,
            ),
            if (!passwordsMatch &&
                confirmPasswordController.text.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                'كلمتا المرور غير متطابقتين',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.error,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
            SizedBox(height: 20.h),
            // Password requirements
            PasswordRequirementsListWidget(
              hasMinLength: hasMinLength,
              hasUppercase: hasUppercase,
              hasLowercase: hasLowercase,
              hasNumber: hasNumber,
              hasSpecialChar: hasSpecialChar,
              notSameAsUsername: notSameAsUsername,
            ),
            SizedBox(height: 0.05.sh),
            // Buttons
            NavigationButtonsWidget(
              onNextPressed: onNextPressed,
              onPreviousPressed: onPreviousPressed,
              isValid: isValid,
              buttonHeight: buttonHeight,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

