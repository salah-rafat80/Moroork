import 'package:traffic/core/widgets/custom_loading_indicator.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/primary_button.dart';
import 'cubits/profile_cubit.dart';
import 'cubits/profile_state.dart';
import 'edit_profile_screen.dart';
import 'widgets/contact_info_card.dart';
import 'widgets/personal_info_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/security_card.dart';
import 'package:traffic/injection_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: const _ProfileScreenBody(),
    );
  }
}

class _ProfileScreenBody extends StatelessWidget {
  const _ProfileScreenBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBg,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Column(
            children: [
              const ProfileHeader(title: 'حسابي'),
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileState state) {
    if (state is ProfileLoading || state is ProfileInitial) {
      return const Center(child: CustomLoadingIndicator());
    }

    if (state is ProfileFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.alertRed,
                fontSize: 14.sp,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => context.read<ProfileCubit>().loadProfile(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final profile = state is ProfileLoadSuccess ? state.profile : null;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSectionTitle('البيانات الشخصية'),
          SizedBox(height: 8.h),
          PersonalInfoCard(
            fullName: profile?.fullName ?? '—',
            nationalId: profile?.nationalId ?? '—',
          ),
          SizedBox(height: 24.h),
          _buildSectionTitle('معلومات التواصل'),
          SizedBox(height: 8.h),
          ContactInfoCard(
            email: profile?.email ?? '—',
            phoneNumber: profile?.phoneNumber ?? '—',
          ),
          SizedBox(height: 24.h),
          _buildSectionTitle('الأمان'),
          SizedBox(height: 8.h),
          SecurityCard(email: profile?.email ?? '—'),
          SizedBox(height: 32.h),
          PrimaryButton(
            label: 'تعديل البيانات',
            onPressed: profile == null
                ? null
                : () {
                    final cubit = context.read<ProfileCubit>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(profile: profile),
                      ),
                    ).then((_) {
                      // Refresh profile after returning from edit
                      cubit.loadProfile();
                    });
                  },
            backgroundColor: AppColors.primary,
          ),
        ],
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
}
