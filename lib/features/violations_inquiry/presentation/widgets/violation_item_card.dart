import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Maps violation titles to their SVG asset paths.
const _violationSvgMap = <String, String>{
  'تجاوز السرعة المقررة': 'assets/تجاوز السرعة المقررة.svg',
  'عدم الربط حزام الامان': 'assets/عدم  ارتداء حزام الامان.svg',
  'عدم  ارتداء حزام الامان': 'assets/عدم  ارتداء حزام الامان.svg',
  'انتظار خاطئ': 'assets/انتظار خاطئ.svg',
};

/// A compact card representing a single selected violation in the review screen.
/// Displays the violation icon, title, violation number, and amount.
class ViolationItemCard extends StatelessWidget {
  final String title;
  final String violationNumber;
  final double amount;

  const ViolationItemCard({
    super.key,
    required this.title,
    required this.violationNumber,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final svgPath = _violationSvgMap[title];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(
          color: AppColors.greyBorder,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // ── Violation icon ──
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.lightGreenBg,
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Center(
              child: svgPath != null
                  ? SvgPicture.asset(
                      svgPath,
                      width: 28.w,
                      height: 28.h,
                    )
                  : Icon(
                      Icons.warning_amber_rounded,
                      size: 24.w,
                      color: AppColors.primary,
                    ),
            ),
          ),

          SizedBox(width: 10.w),

          // ── Title & violation number ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  violationNumber,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // ── Amount ──
          Text(
            '${amount.toInt()} جنية مصري',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

