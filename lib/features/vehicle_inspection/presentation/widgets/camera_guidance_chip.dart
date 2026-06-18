import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A small pill-shaped chip that displays a guidance message to the user
/// while using the camera, e.g. "تأكد من ظهور المركبة بالكامل".
class CameraGuidanceChip extends StatelessWidget {
  /// The guidance message text to display.
  final String message;

  const CameraGuidanceChip({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.dividerLight,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Text(
            message,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.softGrey,
            ),
          ),
          SizedBox(width: 6.w),
          Icon(Icons.info_outline, size: 16.w, color: AppColors.inputHint),
        ],
      ),
    );
  }
}
