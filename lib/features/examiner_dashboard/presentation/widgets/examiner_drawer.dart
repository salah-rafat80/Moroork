import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/features/auth/data/repositories/auth_repository.dart';
import 'package:traffic/features/auth/presentation/screens/login_screen/login_screen.dart';
import 'package:traffic/injection_container.dart';

class ExaminerDrawer extends StatelessWidget {
  const ExaminerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      width: 260.w,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 60.h),
              child: Center(
                child: Image.asset('assets/logo.png', height: 80.h),
              ),
            ),
            Divider(color: AppColors.dividerGrey, thickness: 1, height: 1),
            const Spacer(),
            // ── Logout Button ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(16.r),
              child: ElevatedButton(
                onPressed: () async {
                  final authRepository = getIt<AuthRepository>();
                  await authRepository.logout();
                  
                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alertRed,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
