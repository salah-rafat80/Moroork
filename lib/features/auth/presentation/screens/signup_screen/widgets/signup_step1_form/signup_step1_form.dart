import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/app_sizes.dart';
import 'package:traffic/core/widgets/custom_text_field.dart';
import 'widgets/form_title_widget.dart';
import 'widgets/field_label_widget.dart';
import 'widgets/error_message_widget.dart';
import 'widgets/phone_field_widget.dart';
import 'widgets/next_button_widget.dart';

class SignupStep1Form extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String? usernameError;
  final String? emailError;
  final String? phoneError;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onNextPressed;
  final bool isValid;

  const SignupStep1Form({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.phoneController,
    this.usernameError,
    this.emailError,
    this.phoneError,
    required this.onUsernameChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onNextPressed,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    // Use responsive sizing from context
    final horizontalPadding = context.isLargeScreen
        ? context.spacingXxl
        : (context.isTablet ? context.spacingXl : context.spacingL);
    final buttonHeight = context.isTablet
        ? context.buttonHeightL
        : context.buttonHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxWidth: context.isLargeScreen
                  ? AppSizes.maxContentWidth
                  : double.infinity,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const FormTitleWidget(title: 'معلومات التواصل'),
                    SizedBox(height: 20.h),
                    // Username field
                    const FieldLabelWidget(label: 'اسم المستخدم'),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      controller: usernameController,
                      hintText: 'أدخل اسم المستخدم',
                      textAlign: TextAlign.right,
                      hasError: usernameError != null,
                      onChanged: onUsernameChanged,
                    ),
                    ErrorMessageWidget(errorMessage: usernameError),
                    SizedBox(height: 10.h),
                    // Email field
                    const FieldLabelWidget(label: 'البريد الإلكتروني'),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'أدخل البريد الإلكتروني',
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.emailAddress,
                      hasError: emailError != null,
                      onChanged: onEmailChanged,
                    ),
                    ErrorMessageWidget(errorMessage: emailError),
                    SizedBox(height: 10.h),
                    // Phone field
                    const FieldLabelWidget(label: 'رقم الهاتف'),
                    SizedBox(height: 5.h),
                    PhoneFieldWidget(
                      controller: phoneController,
                      error: phoneError,
                      onChanged: onPhoneChanged,
                    ),
                    ErrorMessageWidget(errorMessage: phoneError),
                    const Spacer(),
                    // Next button
                    SizedBox(height: 24.h),
                    NextButtonWidget(
                      onPressed: onNextPressed,
                      isValid: isValid,
                      height: buttonHeight,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
