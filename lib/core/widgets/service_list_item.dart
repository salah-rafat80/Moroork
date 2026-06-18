import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

/// A rounded card row used in service screens (رخصة القيادة, رخصة المركبة).
///
/// Layout (RTL):  [  label text  ←──────→  green icon  ]
class ServiceListItem extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback? onTap;

  const ServiceListItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // ── Icon container (right side in RTL) ──
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                color: AppColors.extraLightGrey,
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Center(
                child: SizedBox(
                  width: 30.w,
                  height: 23.h,
                  child: SvgPicture.asset(icon),
                ),
              ),
            ),
            SizedBox(width: 7.w),

            // ── Title text ──
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: 'Cairo', 
                  fontSize: 15.sp,
                  // letterSpacing: -0.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  // height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
