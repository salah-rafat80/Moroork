import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/primary_button.dart';
import 'cubits/change_password_cubit.dart';
import 'cubits/change_password_state.dart';
import 'widgets/profile_header.dart';

class ConfirmPasswordResetScreen extends StatefulWidget {
  final String email;
  final String newPassword;

  const ConfirmPasswordResetScreen({
    super.key,
    required this.email,
    required this.newPassword,
  });

  @override
  State<ConfirmPasswordResetScreen> createState() => _ConfirmPasswordResetScreenState();
}

class _ConfirmPasswordResetScreenState extends State<ConfirmPasswordResetScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onConfirm(BuildContext context) {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء إدخال رمز التحقق كاملاً')),
      );
      return;
    }

    context.read<ChangePasswordCubit>().confirmReset(
      email: widget.email,
      code: code,
      newPassword: widget.newPassword,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم تغيير كلمة المرور بنجاح'),
              backgroundColor: AppColors.primary,
            ),
          );
          // Pop back to the profile screen (2 pops: OTP screen + change password screen)
          int popCount = 0;
          Navigator.of(context).popUntil((_) => popCount++ >= 2);
        } else if (state is ChangePasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.cardBg,
          body: Column(
            children: [
              const ProfileHeader(title: 'تأكيد التغيير'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                  child: Column(
                    children: [
                      Text(
                        'أدخل رمز التحقق',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20.sp,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'تم إرسال رمز التحقق إلى بريدك الإلكتروني\n${widget.email}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.softGrey,
                          fontSize: 14.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        textDirection: TextDirection.ltr,
                        children: List.generate(6, (index) => _buildOtpBox(index)),
                      ),
                      SizedBox(height: 48.h),
                      PrimaryButton(
                        label: state is ChangePasswordLoading ? '' : 'تأكيد',
                        onPressed: state is ChangePasswordLoading ? null : () => _onConfirm(context),
                      ),
                      if (state is ChangePasswordLoading)
                        Center(child: CustomLoadingIndicator(color: AppColors.primary)),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: state is ChangePasswordLoading 
                          ? null 
                          : () => context.read<ChangePasswordCubit>().requestOTP(widget.email),
                        child: Text(
                          'إعادة إرسال الرمز',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45.w,
      height: 55.h,
      decoration: BoxDecoration(
          color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
