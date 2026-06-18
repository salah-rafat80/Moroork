import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final String? trailingText;
  final bool showDivider;
  final bool hideArrow;

  const SettingsMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.trailingText,
    this.showDivider = true,
    this.hideArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      textDirection: TextDirection.rtl,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: AppColors.activeGreenLightBg,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18.w),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (trailingText != null) ...[
                  Text(
                    trailingText!,
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 15.sp,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!hideArrow) SizedBox(width: 8.w),
                ],
                if (!hideArrow)
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppColors.primary,
                    size: 14.w,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: AppColors.greyBorder,
            indent: 16.w,
            endIndent: 16.w,
          ),
      ],
    );
  }
}
