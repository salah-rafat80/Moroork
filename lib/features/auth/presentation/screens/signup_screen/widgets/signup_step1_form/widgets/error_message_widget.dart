import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String? errorMessage;

  const ErrorMessageWidget({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Text(
        errorMessage!,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.alertRed,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }
}
