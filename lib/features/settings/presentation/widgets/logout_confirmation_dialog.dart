import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/auth/presentation/screens/login_screen/login_screen.dart';
import 'package:traffic/features/auth/data/repositories/auth_repository.dart';
import 'package:traffic/injection_container.dart';


class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 343.w,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        decoration: ShapeDecoration(
          color: AppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          shadows: [
            BoxShadow(
              color: AppColors.shadowOverlay,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'هل انت متأكد من رغبتك في تسجيل الخروج ؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17.sp,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.h),
            InkWell(
              onTap: () async {
                final authRepository = getIt<AuthRepository>();
                await authRepository.logout();
                
                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(5.r),
              child: Container(
                width: double.infinity,
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.alertRed,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(5.r),
              child: Container(
                width: double.infinity,
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.w,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'الغاء',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18.sp,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
