import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A single RTL bullet-point row with a check-circle icon and text.
/// Used on the vehicle inspection landing screen to display feature highlights.
class InspectionBulletPoint extends StatelessWidget {
  /// The text to display next to the checkmark icon.
  final String text;

  const InspectionBulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Icon(
            Icons.check_circle,
            size: 20.w,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
