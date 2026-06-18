import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'profile_info_row.dart';

class ContactInfoCard extends StatelessWidget {
  final String email;
  final String phoneNumber;

  const ContactInfoCard({
    super.key,
    required this.email,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
            label: 'البريد الالكتروني',
            value: email,
            icon: Icons.email_outlined,
          ),
          Divider(color: AppColors.greyBorder, thickness: 1.r),
          ProfileInfoRow(
            label: 'رقم الهاتف',
            value: phoneNumber,
            icon: Icons.phone_outlined,
          ),
        ],
      ),
    );
  }
}
