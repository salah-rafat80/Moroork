import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/primary_button.dart';
import '../../lost_license/presentation/widgets/custom_text_form_field.dart';
import '../../profile/data/models/profile_model.dart';
import 'confirm_email_change_screen.dart';
import 'cubits/profile_cubit.dart';
import 'cubits/profile_state.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_info_row.dart';
import 'widgets/security_card.dart';
import 'package:traffic/injection_container.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _currentEmail => widget.profile.email;
  bool get _emailChanged =>
      _emailController.text.trim() != _currentEmail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileEmailChangeRequested) {
            // Navigate to OTP confirmation, passing the cubit down
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ProfileCubit>(),
                  child: ConfirmEmailChangeScreen(
                    newEmail: state.newEmail,
                  ),
                ),
              ),
            );
          } else if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;
          return Scaffold(
            backgroundColor: AppColors.lightGreyBg,
            body: Column(
              children: [
                const ProfileHeader(title: 'حسابي'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 20.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildSectionTitle('البيانات الشخصية'),
                          SizedBox(height: 8.h),
                          _buildPersonalInfoCard(),
                          SizedBox(height: 24.h),
                          _buildSectionTitle('معلومات التواصل'),
                          SizedBox(height: 8.h),
                          _buildContactInfoCard(),
                          SizedBox(height: 24.h),
                          _buildSectionTitle('الأمان'),
                          SizedBox(height: 8.h),
                          SecurityCard(email: widget.profile.email),
                          SizedBox(height: 32.h),
                          if (isLoading)
                            const Center(child: CustomLoadingIndicator())
                          else
                            PrimaryButton(
                              label: 'حفظ التغيرات',
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_emailChanged) {
                                    context
                                        .read<ProfileCubit>()
                                        .requestEmailChange(
                                          newEmail:
                                              _emailController.text.trim(),
                                        );
                                  } else {
                                    // No changes — just go back
                                    Navigator.pop(context);
                                  }
                                }
                              },
                              backgroundColor: AppColors.primary,
                            ),
                          SizedBox(height: 16.h),
                          _buildCancelButton(),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17.sp,
        fontFamily: 'Tajawal',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: AppColors.greyBorder, width: 1.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileInfoRow(
            label: 'الاسم الكامل',
            value: widget.profile.fullName,
            icon: Icons.person_outline,
            trailing: _buildReadOnlyBadge(),
          ),
          Divider(color: AppColors.greyBorder, thickness: 1.r),
          ProfileInfoRow(
            label: 'الرقم القومي',
            value: widget.profile.nationalId,
            icon: Icons.badge_outlined,
            trailing: _buildReadOnlyBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.borderMedium,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        'غير قابل للتعديل',
        style: TextStyle(
          color: AppColors.mediumGrey,
          fontSize: 9.sp,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: AppColors.greyBorder, width: 1.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomTextFormField(
            labelText: 'البريد الالكتروني',
            hintText: 'ادخل البريد الالكتروني',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'برجاء إدخال البريد الالكتروني';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}')
                  .hasMatch(value)) {
                return 'برجاء إدخال بريد الكتروني صحيح';
              }
              return null;
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'سيتم إرسال رمز تحقق عند تغيير البريد الالكتروني',
              style: TextStyle(
                color: AppColors.alertRed,
                fontSize: 10.sp,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Divider(color: AppColors.greyBorder, thickness: 1.r),
          SizedBox(height: 16.h),
          ProfileInfoRow(
            label: 'رقم الهاتف',
            value: widget.profile.phoneNumber,
            icon: Icons.phone_outlined,
            trailing: _buildReadOnlyBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(5.r),
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: AppColors.primary, width: 1.r),
        ),
        child: Center(
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
      ),
    );
  }
}
