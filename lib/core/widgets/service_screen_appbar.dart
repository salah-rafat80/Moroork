import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared AppBar for service screens (رخصة القيادة, رخصة المركبة, المساعد الذكي).
///
/// Layout (RTL):
///   [← back arrow]  [title centered]  [☰ hamburger]
class ServiceScreenAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final bool showBackButton;

  const ServiceScreenAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.onMenuPressed,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.only(top: 5.h),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              GestureDetector(
                onTap:
                    onMenuPressed ??
                    () => Scaffold.maybeOf(context)?.openDrawer(),
                child: Icon(
                  Icons.menu,
                  size: 24.w,
                  color: AppColors.textPrimary,
                ),
              ),
              // ── Title (Center) ──
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ),

              if (showBackButton)
                GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    'assets/weui_arrow-filled.svg',
                    width: 24.w,
                    height: 24.w,
                    colorFilter: ColorFilter.mode(
                      AppColors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              else
                SizedBox(width: 24.w),
            ],
          ),
        ),
      ),
    );
  }
}
