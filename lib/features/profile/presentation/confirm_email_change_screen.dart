import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/primary_button.dart';
import '../../lost_license/presentation/widgets/custom_text_form_field.dart';
import 'cubits/profile_cubit.dart';
import 'cubits/profile_state.dart';
import 'widgets/profile_header.dart';

/// OTP verification screen shown after the user requests an email change.
/// Receives the [newEmail] being confirmed and the [cubit] already provided
/// by [EditProfileScreen].
class ConfirmEmailChangeScreen extends StatefulWidget {
  final String newEmail;

  const ConfirmEmailChangeScreen({
    super.key,
    required this.newEmail,
  });

  @override
  State<ConfirmEmailChangeScreen> createState() =>
      _ConfirmEmailChangeScreenState();
}

class _ConfirmEmailChangeScreenState extends State<ConfirmEmailChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileEmailChangeConfirmed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تغيير البريد الإلكتروني بنجاح')),
          );
          // Pop back to ProfileScreen
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is ProfileFailure) {
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
              const ProfileHeader(title: 'حسابي'),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'تأكيد البريد الإلكتروني',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20.sp,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'تم إرسال رمز التحقق إلى:\n${widget.newEmail}',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: AppColors.mediumGrey,
                            fontSize: 13.sp,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(height: 24.h),
                        CustomTextFormField(
                          labelText: 'رمز التحقق',
                          hintText: 'ادخل الرمز المرسل إلى بريدك',
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'برجاء إدخال رمز التحقق';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32.h),
                        if (state is ProfileLoading)
                          const Center(child: CustomLoadingIndicator())
                        else
                          PrimaryButton(
                            label: 'تأكيد',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ProfileCubit>().confirmEmailChange(
                                      newEmail: widget.newEmail,
                                      code: _codeController.text.trim(),
                                    );
                              }
                            },
                            backgroundColor: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
