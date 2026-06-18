import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TestResultButtons extends StatelessWidget {
  final String passLabel;
  final String failLabel;
  final VoidCallback onPass;
  final VoidCallback onFail;

  const TestResultButtons({
    super.key,
    required this.passLabel,
    required this.failLabel,
    required this.onPass,
    required this.onFail,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsetsDirectional.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: AppColors.primary, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4.r,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تسجيل النتيجة',
              style: TextStyle(
                color: AppColors.charcoal,
                fontSize: 16.sp,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    text: passLabel,
                    color: AppColors.primary,
                    onPressed: onPass,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: _buildButton(
                    text: failLabel,
                    color: AppColors.alertRed,
                    onPressed: onFail,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
