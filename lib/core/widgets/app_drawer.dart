// path: lib/core/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traffic/features/home/presentation/screens/main_navigation_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateTo(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(initialIndex: index),
      ),
      (route) => false,
    );
  }

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
              padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 60.h),
              child: Align(
                alignment: Alignment.centerRight,
                child: Center(
                  child: Image.asset('assets/logo.png', height: 80.h),
                ),
              ),
            ),
            // SizedBox(height: 60.h),

            // ── Divider ───────────────────────────────────────────────────────
            Divider(color: AppColors.dividerGrey, thickness: 1, height: 1),

            SizedBox(height: 8.h),

            // ── Menu Items ───────────────────────────────────────────────────
            _DrawerItem(
              label: 'الصفحة الرئيسية',
              iconAsset: 'assets/home.svg',
              onTap: () => _navigateTo(context, 3),
            ),
            Divider(color: AppColors.dividerGrey, thickness: 1, height: 1),

            SizedBox(height: 8.h),
            _DrawerItem(
              label: 'طلباتي',
              iconAsset: 'assets/order.svg',
              onTap: () => _navigateTo(context, 2),
            ),
            Divider(color: AppColors.dividerGrey, thickness: 1, height: 1),

            SizedBox(height: 8.h),
            _DrawerItem(
              label: 'الاعدادات',
              iconAsset: 'assets/settings.svg',
              onTap: () => _navigateTo(context, 1),
            ),
            Divider(color: AppColors.dividerGrey, thickness: 1, height: 1),

            SizedBox(height: 8.h),
            _DrawerItem(
              label: 'حسابي',
              iconAsset: 'assets/profile.svg',
              onTap: () => _navigateTo(context, 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
        child: Row(
          // RTL: icon on the right, text on the left
          textDirection: TextDirection.rtl,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 28.w,
              height: 28.w,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 16.w),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
