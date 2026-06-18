import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traffic/core/constants/colors.dart';
import 'package:traffic/core/theme/theme_cubit.dart';

class ThemeSelectionCard extends StatelessWidget {
  const ThemeSelectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentMode) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.greyBorder,
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withValues(alpha: 0.05),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    'مظهر التطبيق',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.palette_outlined,
                    color: AppColors.primary,
                    size: 20.w,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: _buildThemeOption(
                      context: context,
                      title: 'تلقائي',
                      subtitle: 'حسب النظام',
                      icon: Icons.settings_brightness_outlined,
                      mode: ThemeMode.system,
                      isSelected: currentMode == ThemeMode.system,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildThemeOption(
                      context: context,
                      title: 'مضيء',
                      subtitle: 'وضع النهار',
                      icon: Icons.light_mode_outlined,
                      mode: ThemeMode.light,
                      isSelected: currentMode == ThemeMode.light,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildThemeOption(
                      context: context,
                      title: 'داكن',
                      subtitle: 'وضع الليل',
                      icon: Icons.dark_mode_outlined,
                      mode: ThemeMode.dark,
                      isSelected: currentMode == ThemeMode.dark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<ThemeCubit>().setThemeMode(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.lightGreyBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.greyBorder,
            width: isSelected ? 1.5.w : 1.w,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24.w,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 14.sp,
                fontFamily: 'Tajawal',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
