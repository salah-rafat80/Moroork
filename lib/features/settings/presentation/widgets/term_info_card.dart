import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermInfoCard extends StatelessWidget {
  final String title;
  final String content;

  const TermInfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: ShapeDecoration(
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.w, color: AppColors.greyBorder),
          borderRadius: BorderRadius.circular(5.r),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Text(
            title,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 10.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
