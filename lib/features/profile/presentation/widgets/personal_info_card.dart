import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'profile_info_row.dart';

class PersonalInfoCard extends StatelessWidget {
  final String fullName;
  final String nationalId;

  const PersonalInfoCard({
    super.key,
    required this.fullName,
    required this.nationalId,
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
            label: 'الاسم الكامل',
            value: fullName,
            icon: Icons.person_outline,
          ),
          Divider(color: AppColors.greyBorder, thickness: 1.r),
          ProfileInfoRow(
            label: 'الرقم القومي',
            value: nationalId,
            icon: Icons.badge_outlined,
            trailing: Container(
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
            ),
          ),
        ],
      ),
    );
  }
}
