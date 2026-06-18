import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/password_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'cubits/change_password_cubit.dart';
import 'cubits/change_password_state.dart';
import 'widgets/profile_header.dart';
import 'package:traffic/injection_container.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;

  const ChangePasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var n in _otpFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء إدخال رمز التحقق كاملاً')),
      );
      return;
    }

    context.read<ChangePasswordCubit>().confirmReset(
          email: widget.email,
          code: _otpCode,
          newPassword: _newPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChangePasswordCubit>()..requestOTP(widget.email),
      child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordOTPSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم إرسال رمز التحقق إلى بريدك الإلكتروني'),
                backgroundColor: AppColors.primary,
              ),
            );
          } else if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم تغيير كلمة المرور بنجاح'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context);
          } else if (state is ChangePasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is ChangePasswordLoading;
          final bool otpSent = state is ChangePasswordOTPSent ||
              state is ChangePasswordFailure;

          return Scaffold(
            backgroundColor: AppColors.cardBg,
            body: Column(
              children: [
                const ProfileHeader(title: 'تغيير كلمة المرور'),
                Expanded(
                  child: _buildBody(context, state, isLoading, otpSent),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChangePasswordState state,
    bool isLoading,
    bool otpSent,
  ) {
    // Show loading while sending OTP
    if (state is ChangePasswordLoading && !otpSent) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLoadingIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'جاري إرسال رمز التحقق...',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Show the form once OTP is sent (or if there's an error to allow retry)
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── OTP Section ──
            Text(
              'رمز التحقق',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17.sp,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'تم إرسال رمز التحقق إلى بريدك الإلكتروني\n${widget.email}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.softGrey,
                fontSize: 13.sp,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              textDirection: TextDirection.ltr,
              children: List.generate(6, (index) => _buildOtpBox(index)),
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () => context
                        .read<ChangePasswordCubit>()
                        .requestOTP(widget.email),
                child: Text(
                  'إعادة إرسال الرمز',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ── New Password Section ──
            PasswordTextField(
              labelText: 'كلمة المرور الجديدة',
              hintText: 'ادخل كلمة المرور الجديدة',
              controller: _newPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'برجاء إدخال كلمة المرور الجديدة';
                }
                if (value.length < 8) {
                  return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'يجب أن تحتوي على حرف صغير واحد على الأقل';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'يجب أن تحتوي على رقم واحد على الأقل';
                }
                if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  return 'يجب أن تحتوي على رمز خاص (!@#\$%...)';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),

            // ── Confirm Password Section ──
            PasswordTextField(
              labelText: 'تأكيد كلمة المرور',
              hintText: 'ادخل تأكيد كلمة المرور',
              controller: _confirmPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'برجاء إدخال تأكيد كلمة المرور';
                }
                if (value != _newPasswordController.text) {
                  return 'كلمة المرور غير متطابقة';
                }
                return null;
              },
            ),
            SizedBox(height: 48.h),

            // ── Submit Button ──
            PrimaryButton(
              label: 'تغيير كلمة المرور',
              isLoading: isLoading,
              onPressed: isLoading ? null : () => _onSubmit(context),
              backgroundColor: AppColors.primary,
            ),
            SizedBox(height: 16.h),

            // ── Cancel Button ──
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                side: BorderSide(color: AppColors.primary, width: 1.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
                backgroundColor: AppColors.cardBg,
              ),
              child: Text(
                'الغاء',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
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
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
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
            _otpFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
