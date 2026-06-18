import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/primary_button.dart';

class SupportOptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String buttonText;
  final VoidCallback onActionPressed;

  const SupportOptionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.buttonText,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppColors.primary, width: 1.w),
        borderRadius: BorderRadius.circular(5.r),
      ),
      padding: EdgeInsets.all(8.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const Spacer(),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 13.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                  ),
                  textDirection: TextDirection
                      .ltr, // Preserve layout for emails/phone numbers
                ),
              ],
            ],
          ),
          SizedBox(height: 16.h),
          PrimaryButton(
            label: buttonText,
            onPressed: onActionPressed,
            backgroundColor: AppColors.primary,
            height: 40.h,
            fontSize: 16.sp,
          ),
        ],
      ),
    );
  }
}
