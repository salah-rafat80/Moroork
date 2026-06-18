import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.alertRedLightSoft,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: const Color(0xFFFEE2E2),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Icon(
                Icons.logout,
                color: AppColors.alertRed,
                size: 18.w,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                color: AppColors.alertRed,
                fontSize: 16.sp,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
